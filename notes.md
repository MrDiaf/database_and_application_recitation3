Measurement record:
- 4 byte id of the measurement 
- 8 byte encoding of the GPs
- 8 bytes encoding of error/device 
- 8 bytes for timestamp 

- every **minute** positions are collect from every device 

8KB for a disk-block
- 64-bit address

B+tree vertices fit into exactly one disk block and have 64bit addresses
- 64-bit addresses (8 bytes per pointer)

we cluster on time stamps and build a sparse index on time stamps 

Assume timestamps for a primary key, 10 000 people for 100days 

blocking factor: how many records fits in a block 

1. For the measurement data, what is the blocking factor for a B+ tree leaf node with forward and
backward pointer to next/previous blocks

**answer**
```python 
total_bytes_in_block = 8 * 2^10  
total_bytes_in_block -= 8 * 2 #taking to account for the forward and backward pointer 

record_size = 4 # measurement id
record_size += 8 # GPS encoding 
record_size += 8 # error encoding 
record_size += 8 # timestamp 

blocking_factor = total_bytes_in_block / record_size

```