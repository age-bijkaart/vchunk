## Members

* [vchunk-test](#vchunk-test)

## Constants

* [total_length](#total_length)

<a name="vchunk-test"></a>

## vchunk-test
Test program for the [VCHUNK](./README.md) 
(virtual chunk) module.

**Kind**: global variable  

* * *

<a name="total_length"></a>

## total_length
what happens: ('bi' stands for initial_buf, b[j] for buffers[j])
    the numbers begin, end, last are for the circular buffer
```javascript
     [ bi, undef, undef ] begin = 0, end = 1, last = 0
  => [ bi, b[0], undef ] begin = 0, end = 2, last = 1
  => [ bi, b[0], b[1] ] begin = 0, end = 0, last = 2
  => [ b[2], b[0], b[1] ] begin = 1, end = 1, last = 0
```

**Kind**: global constant  

* * *

