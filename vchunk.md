## Modules

<dl>
<dt><a href="#module_VCHUNK">VCHUNK</a></dt>
<dd><p>The module exports 2 objects</p>
<pre><code class="lang-javascript">  module.exports = { VChunk, VCursor };
</code></pre>
<p>representing the operations on a virtual chunk and a cursor, respectively.</p>
</dd>
</dl>

## Constants

* [CURSORS](#CURSORS)
* [VINDEX](#VINDEX)
* [VChunk](#VChunk)
* [VCursor](#VCursor)

## Functions

* [vchunk_create(capacity)](#vchunk_create) ⇒ [<code>VChunk</code>](#VChunk)
* [vchunk_push(vchunk, buffer)](#vchunk_push) ⇒ <code>Boolean</code>
* [vchunk_del_cursor(vchunk, c)](#vchunk_del_cursor) ⇒ <code>Boolean</code>
* [vchunk_begin(vchunk)](#vchunk_begin) ⇒ <code>Integer</code>
* [vchunk_end(vchunk)](#vchunk_end) ⇒ <code>Integer</code>
* [vchunk_tostring(vchunk, short)](#vchunk_tostring) ⇒ <code>String</code>
* [vcursor_create(vchunk)](#vcursor_create) ⇒ [<code>VCursor</code>](#VCursor)
* [vcursor_clone(c)](#vcursor_clone) ⇒ [<code>VCursor</code>](#VCursor)
* [vcursor_eof(c)](#vcursor_eof) ⇒ <code>Boolean</code>
* [vcursor_in_buffer(c, a)](#vcursor_in_buffer) ⇒ <code>Boolean</code>
* [vcursor_in_chunk_with_index(c, chunk_index)](#vcursor_in_chunk_with_index) ⇒ <code>Boolean</code>
* [vcursor_cindex(c)](#vcursor_cindex) ⇒ <code>undefined</code> \| <code>Integer</code>
* [vcursor_chunk(c)](#vcursor_chunk) ⇒ <code>Chunk</code>
* [vcursor_move(c, size)](#vcursor_move) ⇒ <code>Integer</code>
* [vcursor_at(c)](#vcursor_at) ⇒ <code>Byte</code>
* [vcursor_atmove(c)](#vcursor_atmove) ⇒ <code>Byte</code>
* [vcursor_tostring(c, short)](#vcursor_tostring) ⇒ <code>String</code>
* [vcursor_read_int32(c)](#vcursor_read_int32) ⇒ <code>Integer</code>
* [vcursor_read_int16(c)](#vcursor_read_int16) ⇒ <code>Integer</code>
* [vcursor_read_cstring(c)](#vcursor_read_cstring) ⇒ <code>string</code>
* [vcursor_read_chars(c, n)](#vcursor_read_chars) ⇒ <code>Array</code>
* [vcursor_read_bytes(c, n)](#vcursor_read_bytes) ⇒ <code>Array</code>
* [vcursor_read_char(c)](#vcursor_read_char) ⇒ <code>string</code>
* [vcursor_read_byte(c)](#vcursor_read_byte) ⇒ <code>Integer</code>
* [vcursor_read_string(c, size)](#vcursor_read_string) ⇒ <code>string</code>
* [vcursor_read_str_int(c, size)](#vcursor_read_str_int) ⇒ <code>Integer</code>
* [vcursor_read_date(c, size)](#vcursor_read_date) ⇒ <code>Date</code>

<a name="module_VCHUNK"></a>

## VCHUNK
The module exports 2 objects
```javascript
  module.exports = { VChunk, VCursor };
```
representing the operations on a virtual chunk and a cursor, respectively.

**See**

- VChunk
- VCursor
```javascript
const VChunk = {
  create: vchunk_create, 
  push: vchunk_push, 
  del_cursor: vchunk_del_cursor,

  cursors: (vchunk) => (vchunk[CURSORS]),
  begin: vchunk_begin,
  end: vchunk_end, 

  tostring: vchunk_tostring, 
};

const VCursor = {
  create: vcursor_create, 
  vindex: ((cursor) => (cursor[VINDEX])),
  clone: vcursor_clone,
  eof: vcursor_eof,
  
  move: vcursor_move,

  at: vcursor_at,
  atmove: vcursor_atmove,

  read_int32: vcursor_read_int32,
  read_int16: vcursor_read_int16,
  read_cstring: vcursor_read_cstring,
  read_chars: vcursor_read_chars,
  read_char: vcursor_read_char,
  read_bytes: vcursor_read_bytes,
  read_byte: vcursor_read_byte,
  read_string: vcursor_read_string,
  read_date: vcursor_read_date,
  read_str_int: vcursor_read_str_int,

  tostring: vcursor_tostring
};
```

**Todo**

- [ ] VChunk.reset which resets the offset of the first chunk to 0 and adapts
all other chunks.offset and cursor.vindex by substracting old_offset 
from it. VChunk.reset could for instance be called by a postgresql client after each
query result.


* * *

<a name="CURSORS"></a>

## CURSORS
Name (using a 
[Symbol](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol)) 
of a data property for a virtual chunk, in addition to those of CBUF.

**Kind**: global constant  
**Example**  
```js
import CBUF from '@dvermeir/cbuf';

const CURSORS = Symbol('cursors');

function vchunk_create(capacity) {
  let vchunk = CBUF.create(capacity);
  vchunk[CURSORS] = new Set();
  return vchunk;
}
```

* * *

<a name="VINDEX"></a>

## VINDEX
Name (using a 
[Symbol](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol)) of data properties of vchunk cursors objects.
```javascript
const VINDEX = Symbol('vindex');
const VCHUNK = Symbol('vchunk');
```

- VINDEX is the 'virtual index' into the virtual chunk on which the cursor 
  is defined
- VCHUNK is an immutable reference to the virtual chunk on which the cursor
  is defined

**Kind**: global constant  
**Example**  
```js
function vcursor_create(vchunk) {
  const c = Object.defineProperty(
   { [VINDEX]: vchunk_begin(vchunk) }, 
   VCHUNK, { enumerable: true, value: vchunk, configurable: false, writable: false }
  );
  vchunk[CURSORS].add(c);
  return c;
}
```

* * *

<a name="VChunk"></a>

## VChunk
**Kind**: global constant  
**Description.**: An object `VChunk` containing exported functions that operate on a virtual
chunk.
```javascript
const VChunk = {
  create: vchunk_create, 
  push: vchunk_push, 
  del_cursor: vchunk_del_cursor,

  cursors: (vchunk) => (vchunk[CURSORS]),
  begin: vchunk_begin,
  end: vchunk_end, 

  tostring: vchunk_tostring, 
};
```  

* * *

<a name="VCursor"></a>

## VCursor
**Kind**: global constant  
**Description.**: An object `VCursor` containing exported functions that operate on a virtual
cursor.
```javascript
const VCursor = {
  create: vcursor_create, 
  vindex: ((cursor) => (cursor[VINDEX])),
  vchunk: ((cursor) => (cursor[VCHUNK])),
  clone: vcursor_clone,
  eof: vcursor_eof,
  
  move: vcursor_move,

  at: vcursor_at,
  atmove: vcursor_atmove,

  read_int32: vcursor_read_int32,
  read_int16: vcursor_read_int16,
  read_cstring: vcursor_read_cstring,
  read_chars: vcursor_read_chars,
  read_char: vcursor_read_char,
  read_bytes: vcursor_read_bytes,
  read_byte: vcursor_read_byte,
  read_string: vcursor_read_string,
  read_date: vcursor_read_date,
  read_str_int: vcursor_read_str_int,

  tostring: vcursor_tostring


};
```  

* * *

<a name="vchunk_create"></a>

## vchunk_create(capacity) ⇒ [<code>VChunk</code>](#VChunk)
Create a new empty virtual chunk. Any cursor `c` that is defined on
an empty `vchunk` will point to EOF, i.e. `vcursor_eof(c)`
will be true.

A virtual chunk is actually just a `CBUF` (circular buffer) with one extra
`CURSORS` data attribute which refers to the set of `VCursor` cursors that
point to data in the chunk.

**Kind**: global function  
**Returns**: [<code>VChunk</code>](#VChunk) - newly created empty virtual chunk  
**See**

- vcursor_eof
- vcursor_create

**Params**

- capacity <code>Integer</code> - of the underlying circular buffer

**Example**  
```js
import CBUF from '@dvermeir/cbuf';
import {VChunk, VCursor} from '@dvermeir/vchunk';

const initial_buf = Buffer.from([1,1]);
vchunk = VChunk.create(initial_buf, 3);
```

* * *

<a name="vchunk_push"></a>

## vchunk_push(vchunk, buffer) ⇒ <code>Boolean</code>
Push/append a new buffer/chunk on/to a virtual chunk.

**Kind**: global function  
**Returns**: <code>Boolean</code> - true iff the operation succeeded  
**Throws**:

- <code>Error</code> with name 'CURSORS' if
`vchunk` is full and a shift operation to make room is impossible because
there is at least one cursor pointing into the oldest chunk (that would be
shifted).

**See**: vcursor_create  
**Params**

- vchunk [<code>VChunk</code>](#VChunk) - on which the buffer will be pushed
- buffer <code>Buffer</code> - a nodejs 
[`Buffer`](https://nodejs.org/api/buffer.html#buffer_buffer)

**Example**  
```js
import net from 'net';
 import { VChunk, VCursor } from  'vchunk';

 const conn = net.createConnection(path);
 let chunks = vchunk_create(10);

 conn.on('data', function(buffer) {
   // buffer is a Buffer of data read from the socket
   VChunk.push(chunks, buffer)) 
   ..
 }
 ...
```

* * *

<a name="vchunk_del_cursor"></a>

## vchunk_del_cursor(vchunk, c) ⇒ <code>Boolean</code>
Delete a cursor on a virtual chunk. Note that it is assumed that the
parameter cursor `c` is indeed one of the cursors of the other parameter
`vchunk`. If not, the function will return false.

**Kind**: global function  
**Returns**: <code>Boolean</code> - true iff there was a delete from the set 
 `vchunk[CURSORS]`.  
**See**: [Set.delete] (https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set/delete)  
**Params**

- vchunk [<code>VChunk</code>](#VChunk) - the virtual chunk that the cursor points into
- c [<code>VCursor</code>](#VCursor) - the cursor to be deleted

**Example**  
```js
// The trivial implementation
 const vchunk_del_cursor = (vchunk, c) => ( vchunk[CURSORS].delete(c) );
```

* * *

<a name="vchunk_begin"></a>

## vchunk_begin(vchunk) ⇒ <code>Integer</code>
The virtual index of the beginning of a virtual chunk. Upon creation, this
will be 0 and it will remain 0 as long as the very first buffer that was
pushed onto `vchunk` has not been shifted out to make room for new buffers.

After that,  as older chunks are shifted out to make room for new ones, 
this index will increase. I.e. the indices associated with
shifted chunks are not reused. 

Thus, a virtual chunk represents a sliding window on a stream of buffers
coming in via `vchunk_push` and leaving the window on the other side via
`CBUF.shift` which is called by `vchunk_push` when the underlying circular
buffer is full.

**Kind**: global function  
**Returns**: <code>Integer</code> - the `offset` of the oldest buffer in `vchunk` or 0 if
`vchunk` is empty.  
**Params**

- vchunk [<code>VChunk</code>](#VChunk) - the virtual chunk to find the start index of


* * *

<a name="vchunk_end"></a>

## vchunk_end(vchunk) ⇒ <code>Integer</code>
The `end` virtual index of a virtual chunk. If nonempty, it is equal
to the maximal valid virtual index in the vchunk + 1.

**Kind**: global function  
**Returns**: <code>Integer</code> - the 'end virtual index' of `vchunk` or 0. In both cases
`vchunk_at(vchunk_end(v)) === undefined`.  
**Params**

- vchunk [<code>VChunk</code>](#VChunk) - the virtual chunk to find the end index of


* * *

<a name="vchunk_tostring"></a>

## vchunk_tostring(vchunk, short) ⇒ <code>String</code>
A string representation of a virtual chunk.

**Kind**: global function  
**Returns**: <code>String</code> - a string representation of `vchunk`  
**Params**

- vchunk [<code>VChunk</code>](#VChunk) - the virtual chunk to represent in a string
- short <code>Boolean</code> - if false, the cursors associated with the virtual
 chunk will also be shown in the returned string.


* * *

<a name="vcursor_create"></a>

## vcursor_create(vchunk) ⇒ [<code>VCursor</code>](#VCursor)
Create a virtual cursor for a virtual chunk. The association between a 
cursor an its virtual chunk is immutable.

**Kind**: global function  
**Returns**: [<code>VCursor</code>](#VCursor) - the new cursor pointing to the beginning of the data of vchunk  
**See**: vchunk_begin  
**Params**

- vchunk [<code>VChunk</code>](#VChunk) - the virtual chunk that the new cursor will point into


* * *

<a name="vcursor_clone"></a>

## vcursor_clone(c) ⇒ [<code>VCursor</code>](#VCursor)
Clone a virtual cursor. This might be useful to make a backup copy at a
certain position to fall back to if parsing further input fails.

**Kind**: global function  
**Returns**: [<code>VCursor</code>](#VCursor) - a shallow copy of `c`, made using
[Object.assign](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign)  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor to be cloned


* * *

<a name="vcursor_eof"></a>

## vcursor_eof(c) ⇒ <code>Boolean</code>
Check whether the cursor is a `EOF`, i.e. not pointing at valid data.

**Kind**: global function  
**Returns**: <code>Boolean</code> - true iff the cursor `c`  does not point to valid data  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor to be checked


* * *

<a name="vcursor_in_buffer"></a>

## vcursor_in_buffer(c, a) ⇒ <code>Boolean</code>
This function is not exported. It checks whether the cursor points do data
belonging to a particular chunk `{offset:Integer, buffer:Buffer}` in its
underlying `VChunk`.

**Kind**: global function  
**Returns**: <code>Boolean</code> - true iff `c` points to the Buffer associated with the given chunk  
**See**: vcursor_create  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor to be checked
- a <code>Chunk</code> - element `chunk` of the `c[VCHUNK]` virtual chunk


* * *

<a name="vcursor_in_chunk_with_index"></a>

## vcursor_in_chunk_with_index(c, chunk_index) ⇒ <code>Boolean</code>
This function is not exported. It checks whether the cursor points do data
belonging to a the chunk at a certain position (`index`) in the 
underlying `VChunk`.

**Kind**: global function  
**Returns**: <code>Boolean</code> - true iff `c` points to the Buffer associated with the chunk a
position `chunk_index` in `c[VCHUNK]`, the `VChunk` associated with `c`.  
**See**: vcursor_create  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor to be checked
- chunk_index <code>Integer</code> - an index in the circular buffer underlying
`c[VCHUNK]`.


* * *

<a name="vcursor_cindex"></a>

## vcursor_cindex(c) ⇒ <code>undefined</code> \| <code>Integer</code>
This function is not exported.
 For a cursor `c`, it returns the index `i` in the circular
 buffer `c[VCHUNK]` such that `c` points into the `i`'th chunk's buffer.

**Kind**: global function  
**Returns**: <code>undefined</code> - iff `CBUF.empty(c[VCHUNK])`.<code>Integer</code> - `i` such that 

`v[i].offset <= c[VINDEX] < v[i].offset + v[i].buffer.length`

where

`v = c[VCHUNK]` is the virtual chunk associated with `c`.  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor for which the index will be found


* * *

<a name="vcursor_chunk"></a>

## vcursor_chunk(c) ⇒ <code>Chunk</code>
This function is not exported.
 For a cursor `c`, it returns the chunk `{offset, buffer}` from 
 `c[VCHUNK]` such that `c` points into the chunk's buffer.

**Kind**: global function  
**Returns**: <code>Chunk</code> - `chunk` from `c[VCHUNK]` such that 

`chunk.offset <= c[VINDEX] < chunk.offset +  chunk.buffer.length`  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor for which the chunk will be found


* * *

<a name="vcursor_move"></a>

## vcursor_move(c, size) ⇒ <code>Integer</code>
Move a cursor `size` positions forward.

**Kind**: global function  
**Returns**: <code>Integer</code> - the new index `c[VINDEX]` of `c`  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor to move
- size <code>Integer</code> - the number of bytes to skip


* * *

<a name="vcursor_at"></a>

## vcursor_at(c) ⇒ <code>Byte</code>
Return the data (byte) that the cursor is pointing to.

**Kind**: global function  
**Returns**: <code>Byte</code> - the byte that the cursor is pointing to  
**Throws**:

- <code>Error</code> with name `EOF` if c is at EOF

**See**

- vcursor_eof
- vcursor_create

**Params**

- c [<code>VCursor</code>](#VCursor) - a cursor on some virtual chunk


* * *

<a name="vcursor_atmove"></a>

## vcursor_atmove(c) ⇒ <code>Byte</code>
Return the byte the cursor is pointing to and move the cursor 1 step
forward. This can be trivially implemented:
```javascript
  const vcursor_atmove = (c) =>
    { const b = vcursor_at(c); vcursor_move(c, 1); return b; }
```

**Kind**: global function  
**Returns**: <code>Byte</code> - the byte the cursor was pointing to before it moved  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor to read and move


* * *

<a name="vcursor_tostring"></a>

## vcursor_tostring(c, short) ⇒ <code>String</code>
A string representation of a virtual cursor.

**Kind**: global function  
**Returns**: <code>String</code> - a string representation of `c`  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor to represent in a string
- short <code>Boolean</code> - if false, the virtual chunk `c[VCHUNK]` will also
  be shown in the returned string.


* * *

<a name="vcursor_read_int32"></a>

## vcursor_read_int32(c) ⇒ <code>Integer</code>
VCursor read function.
Read a 32bit integer in
[MSB](https://en.wikipedia.org/wiki/Most_significant_bit) format.
Move the cursor to point to the byte after the integer (or EOF).

**Kind**: global function  
**Returns**: <code>Integer</code> - i the integer read  
**See**: vcursor_eof  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor used for reading


* * *

<a name="vcursor_read_int16"></a>

## vcursor_read_int16(c) ⇒ <code>Integer</code>
VCursor read function.
Read a 16bit integer in
[MSB](https://en.wikipedia.org/wiki/Most_significant_bit) format.
Move the cursor to point to the byte after the integer (or EOF).

**Kind**: global function  
**Returns**: <code>Integer</code> - i the integer read  
**See**: vcursor_eof  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor used for reading


* * *

<a name="vcursor_read_cstring"></a>

## vcursor_read_cstring(c) ⇒ <code>string</code>
VCursor read function.
Read a 'C string', i.e. a sequence of characters followed by a terminating 
0 byte.
Move the cursor to point to the byte after the string (or EOF).

**Kind**: global function  
**Returns**: <code>string</code> - the C string as a JS `string` (not a `String` object)  
**See**: vcursor_eof  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor used for reading


* * *

<a name="vcursor_read_chars"></a>

## vcursor_read_chars(c, n) ⇒ <code>Array</code>
VCursor read function.
Read a given number of characters.
Move the cursor to point to the byte after these characters (or EOF).

**Kind**: global function  
**Returns**: <code>Array</code> - of size `n` containing the sequence of characters read
Each character is obtained by calling [String.fromCharCode](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/fromCharCode)
on each read byte.  
**See**

- vcursor_eof
- [`String.fromCharCode`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/fromCharCode) for limitation on valid caracters, this function really works only with 'ascii' or 'latin1', i.e. 1-byte characters.

**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor used for reading
- n <code>Integer</code> - the number of characters to read


* * *

<a name="vcursor_read_bytes"></a>

## vcursor_read_bytes(c, n) ⇒ <code>Array</code>
VCursor read function.
Read a given number of bytes.
Move the cursor to point to the byte after these characters (or EOF).

**Kind**: global function  
**Returns**: <code>Array</code> - of size `n` containing the sequence of bytes read  
**See**

- vcursor_eof
- vcursor_read_chars

**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor used for reading
- n <code>Integer</code> - the number of bytes to read


* * *

<a name="vcursor_read_char"></a>

## vcursor_read_char(c) ⇒ <code>string</code>
VCursor read function.
Read a single character and advance the cursor by 1 position.

**Kind**: global function  
**Returns**: <code>string</code> - of size `1` containing the character read
The character is obtained by calling [String.fromCharCode](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/fromCharCode)
on the read byte.  
**See**: vcursor_eof  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor used for reading


* * *

<a name="vcursor_read_byte"></a>

## vcursor_read_byte(c) ⇒ <code>Integer</code>
VCursor read function.
Read a single byte and advance the cursor by 1 position.

**Kind**: global function  
**Returns**: <code>Integer</code> - containing the byte read  
**See**: vcursor_eof  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor used for reading


* * *

<a name="vcursor_read_string"></a>

## vcursor_read_string(c, size) ⇒ <code>string</code>
VCursor read function.
Read a given number of characters as a JS `string`.
Move the cursor to point to the byte after these characters (or EOF).

**Kind**: global function  
**Returns**: <code>string</code> - of length `n` containing the sequence of characters read
Each character is obtained by calling [String.fromCharCode](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/fromCharCode)
on each read byte.  
**See**: vcursor_eof  
**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor used for reading
- size <code>Integer</code> - the number of characters to read


* * *

<a name="vcursor_read_str_int"></a>

## vcursor_read_str_int(c, size) ⇒ <code>Integer</code>
VCursor read function.
Read a string and convert (parse) it to an integer.
Move the cursor to point to the byte after the characters read (or EOF).

**Kind**: global function  
**Returns**: <code>Integer</code> - the result of calling
[`parseInt`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/parseInt)
with base `10` on the result of `vcursor_read_string`  
**See**

- vcursor_eof
- vcursor_read_string

**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor used for reading
- size <code>Integer</code> - the number of characters to read


* * *

<a name="vcursor_read_date"></a>

## vcursor_read_date(c, size) ⇒ <code>Date</code>
VCursor read function.
Read a string and convert (parse) it to a JS 
[`Date`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date) object.
Move the cursor to point to the byte after the characters read (or EOF).

**Kind**: global function  
**Returns**: <code>Date</code> - the result of calling
[`new Date(datestr)`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date) 
where `datestr` is the result of calling `vcursor_read_string(c, size)`  
**See**

- vcursor_eof
- vcursor_read_string

**Params**

- c [<code>VCursor</code>](#VCursor) - the cursor used for reading
- size <code>Integer</code> - the number of characters to read


* * *

