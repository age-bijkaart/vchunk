<a id="Top" href="#Top"/>

# Virtual Chunks Version 0.1.N


1. [Overview](#Overview)
2. [API Index](vchunk.md)
3. [API Details](vchunk.md#module_VCHUNK)
4. [VCHUNK test](vchunk-test.md)
5. [NPM](https://www.npmjs.com/package/@dvermeir/vchunk)

<a id="Overview" href="#Top">

# Virtual chunks 

</a>

Sockets deliver data in chunks ([`Buffer`s](https://nodejs.org/api/buffer.html#buffer_buffer) in nodejs parlance). One could imagine the list of incoming
chunks as an array of chunks and a parser could abstract
from the chunks so that e.g. a message whose data cross chunk borders can
be read without the parser being aware of this.

An easy solution is to concatenate the chunks but this copying is what we will
try to avoid in this little package.

Thus we put a view on an array of
[chunks/Buffers](https://nodejs.org/api/buffer.html#buffer_buffer)
as one
continuous array of bytes. Then, starting with the first chunk in the array, we
can parse messages, e.g. communications from a
[postgresql](https://www.postgresql.org/docs/9.6/static/protocol-message-formats.html) server, as if we were
dealing with one big array of bytes, abstracting from the fact that those bytes
may be spread over several
[`Buffer`s](https://nodejs.org/api/buffer.html#buffer_buffer). E.g. a 32bit integer could have 2 bytes 
at the end of one chunk and the rest at the beginning of the next chunk.

In short, a `VChunk` ('Virtual chunk') stands for an array (actually a [circular
buffer](https://github.com/age-bijkaart/cbuf/blob/master/README.md)) of 'chunks' that can be indexed as one virtual array of bytes.

## Invariants

Obviously, since a `VChunk` is also a `CBUF` (Circular buffer), the
invariant of 
such a buffer also holds, see its
[documentation](https://github.com/age-bijkaart/cbuf/blob/master/README.md).

Each chunk in the circular buffer has an `offset` and a `length` that
are related as in the following pseudocode.

```javascript

  let previous_offset = undefined;
  let previous_length = undefined;
  for chunk of vchunk.iterable 
    if (previous_offset)
      assert (chunk.offset === previous_offset + previous_length)
      previous_offset = chunk.offset;
      previous_length = chunk.buffer.length;

  // the following definition will be useful later on
  VChunk.last = CBUF.last(chunk); // defined iff VChunk.pop > 0
  VChunk.end = VChunk.last ?
    VChunk[VChunk.last].offset + VChunk[VChunk.last].buffer.length : 0;
```
# Virtual cursors

Accessing of a `VChunk` goes through a `VCursor` ('Virtual Cursor'). A
`VCursor`
maintains an index in the associated `VChunk`'s virtual array. 

A number of functions are defined on `VCursor` to parse integers,
C strings etc. from the current position of a cursor.
After reading each byte, the cursor advances to point 
to the byte immediately after the data just read, which may be past the last
chunk's data (EOF, end of file).
If EOF is encountered before the read operation is completed, an
[`Error`](https://nodejs.org/api/errors.html#errors_class_error) with name `EOF` is thrown.

Note that when more chunks arrive, they are pushed (appended) onto the end
of the circular buffer and
when this buffer is full, it will `shift` the oldest chunk out. 
If there were any
cursors pointing into this oldest chunk that is about to disappear, an
exception with name `CURSOR` will be thrown.

## Invariants:
For a `VCursor` `cursor` pointing to a chunk `vc`:
```javascript
      cursor.vindex >= vchunk.end // EOF 
      || 
      for chunk of vchunk.iterable 
        exists chunk where
          chunk.offset <= cursor.vindex < chunk.offset + chunk.buffer.length
```
Thus a cursor, if not at EOF, always points to a byte inside of a
[`Buffer`](https://nodejs.org/api/buffer.html#buffer_buffer) from the circular buffer. See the source code.

### Blobs and Buffer.slice

*This part is not yet implemented nor designed.*

## Installation

Standard: 
```bash
      npm install --save vchunk
```

The module depends on the [cbuf](https://www.npmjs.com/package/@dvermeir/cbuf) package.

## API

### Chunk

While chunks will
most often be [nodejs](https://nodejs.org/en/) [Buffer](https://nodejs.org/api/buffer.html)s, 
any type `T` that supports
```javascript
  T[index] // returns byte at position index
  T.length // returns size (in bytes) of the data in t
```
can be used, e.g.
[Uint8Array](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Uint8Array).

### VChunk
```javascript
  vchunk = VChunk.create(chunk: Buffer, capacity: >0) 
```
where `capacity` is the capacity of the underlying 
[circular buffer](https://github.com/age-bijkaart/cbuf/blob/master/README.md)
containing references to chunks/buffers.

```javascript
  VChunk.push(vchunk, chunk: a Buffer): boolean 
```
returns `true` if push succeeded, throws CURSOR
[`Error`](https://nodejs.org/api/errors.html#errors_class_error) if the underlying
[`cbuf`](https://github.com/age-bijkaart/cbuf/blob/master/README.md)
is full and `shift` is impossible because there are active `VCursor`
objects pointing into this oldest chunk/buffer.
  
Other operations on `VChunk` include:
```javascript
VChunk.cursors(vchunk): Set // of VCursor objects pointing to vchunk
VChunk.del_cursor(vchunk, cursor): boolean // true iff cursor was deleted 
```
The `vchunk` can be thought of as an array of bytes with indices 
`[vchunk.begin .. vchunk.end[`:
```javascript
  VChunk.begin(vchunk): int
```
returns the smallest valid index for VCursor in this vchunk,
0 if 
[`CBUF.empty(vchunk)`](https://github.com/age-bijkaart/cbuf/blob/master/README.md)
```javascript
  VChunk.end(vchunk): int
```
returns the largest valid index + 1, or 0 if there are no valid indices,
i.e. if
[`CBUF.empty(vchunk)`](https://github.com/age-bijkaart/cbuf/blob/master/README.md).

### VCursor

To create a virtual cursor (`VCursor`) pointing to the first byte
of the virtual chunk:

```javascript
  vcursor = VCursor.create(vchunk);
```
the new cursor will point to `vchunk[VChunk.begin(vchunk)]]`. If `vchunk` is
empty, the cursor will be at EOF, i.e. `VCursor.eof(vcursor)` will hold.

To read from the underlying chunks and advance the virtual cursor `vc`:
```javascript
  int VCursor.read_int32(vc)
  int VCursor.read_int16(vc)
  string VCursor.read_cstring(vc)
  string VCursor.read_char(vc)
  string VCursor.read_char(vc,n) 
  Date  VCursor.read_date(vc);
```
Each of those will throw an
[`Error`](https://nodejs.org/api/errors.html#errors_class_error)
called `EOF` is there are not
enough data to complete the read operation, i.e. `VCursor.eof(vcursor)`
becomes true while the read operation is still in progress.

In each case, calling `VCursor.read_xxx(cursor)` advances the `cursor` to
the byte
following the bytes composing the object just read.
So, after `VCursor.read_xxx(cursor)`, the `cursor` is ready 
to read the next data.

Reading should not go beyond the most recent chunk in the virtual `vchunk`:
```javascript
  while (VCursor.vindex(vc) < VChunk.end(vchunk)) {
    // read something
  }
```
Other functions:
```javascript
  VCursor.vindex(cursor): int //  index in [begin.. end[ of vchunk
  VCursor.clone(cursor): VCursor
  VCursor.eof(cursor): boolean // true iff cursor is at EOF

  VCursor.move(cursor, length >=0 ): void // skip length bytes

  VCursor.at(cursor): byte // cursor is pointing at
  VCursor.atmove(cursor): byte // at(cursor) followed by move(cursor,1)
```

## Example

```javascript
  import net from 'net';
  import { VChunk, VCursor } from  'vchunk';

  const conn = net.createConnection(path);
  let chunks = vchunk_create(10);

  conn.on('data', function(chunk) {
    VChunk.push(chunks, chunk)

    let p = VCursor.create(chunks);

    while ( VCursor.vindex(p) < VChunk.end(chunks) ) {
      const name = VCursor.read_cstring(p);
      const age = VCursor.read_int16(p); 
    }
  });
```
