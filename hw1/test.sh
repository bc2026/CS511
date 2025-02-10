#!/bin/bash

# Test Case 1. Basic Test: Verify simple file rearrangement
echo "Running Test 1: Basic Test"
echo "Input: 'AAABBBCCCDDDEEE' with chunk size 3 and pattern 'a c b e d'"
echo "Expected Output: 'AAACCCBBBEEEDDD'"
echo "Running: java TextSwap 3 letters.txt < pattern.txt"
java TextSwap 3 letters.txt < pattern.txt
diff output.txt expected_output_1.txt
if [ $? -eq 0 ]; then
  echo "Test 1 Passed"
else
  echo "Test 1 Failed"
fi

# Test Case 2. Check if error is thrown for chunk size not matching file size
echo "Running Test 2: Chunk size not matching file size"
echo "Input: 'AAABBBCCC' with chunk size 4"
echo "Expected Output: Error message 'File size must be a multiple of the chunk size'"
java TextSwap 4 letters.txt
if [ $? -eq 1 ]; then
  echo "Test 2 Passed"
else
  echo "Test 2 Failed"
fi

# Test Case 3. Check if error is thrown for more than 26 chunks
echo "Running Test 3: Chunk size too small (more than 26 chunks)"
echo "Input: 'A-Z'*10 with chunk size 2"
echo "Expected Output: Error message 'Chunk size too small'"
java TextSwap 2 letters.txt
if [ $? -eq 1 ]; then
  echo "Test 3 Passed"
else
  echo "Test 3 Failed"
fi

# Test Case 4. File with a single chunk (no swapping required)
echo "Running Test 4: Single Chunk File"
echo "Input: 'HELLO' with chunk size 5 and pattern 'a'"
echo "Expected Output: 'HELLO'"
echo "Running: java TextSwap 5 single_chunk.txt < pattern.txt"
java TextSwap 5 single_chunk.txt < pattern.txt
diff output.txt expected_output_4.txt
if [ $? -eq 0 ]; then
  echo "Test 4 Passed"
else
  echo "Test 4 Failed"
fi

# Test Case 5. Edge Case: Empty file
echo "Running Test 5: Empty File"
echo "Input: empty.txt with chunk size 3"
echo "Expected Output: empty output.txt"
java TextSwap 3 empty.txt
diff output.txt expected_output_5.txt
if [ $? -eq 0 ]; then
  echo "Test 5 Passed"
else
  echo "Test 5 Failed"
fi

# Test Case 6. Performance Test: Large file
echo "Running Test 6: Performance Test"
echo "Input: large_file.txt with chunk size 1024"
echo "Expected Output: correctly reordered content in output.txt"
java TextSwap 1024 large_file.txt
diff output.txt expected_output_6.txt
if [ $? -eq 0 ]; then
  echo "Test 6 Passed"
else
  echo "Test 6 Failed"
fi

# Test Case 7. Invalid pattern input length
echo "Running Test 7: Invalid pattern length"
echo "Input: 'ABCDEFG' with chunk size 2 and pattern 'a b c'"
echo "Expected Output: Error message 'Invalid rearrangement pattern'"
java TextSwap 2 letters.txt
if [ $? -eq 1 ]; then
  echo "Test 7 Passed"
else
  echo "Test 7 Failed"
fi

# Test Case 8. Check multi-threaded execution
echo "Running Test 8: Multi-threaded Execution"
echo "Input: 'ABCDEFGH' with chunk size 2 and pattern 'd c b a'"
echo "Expected Output: 'GHEFCDAB'"
java TextSwap 2 letters.txt < pattern.txt
diff output.txt expected_output_8.txt
if [ $? -eq 0 ]; then
  echo "Test 8 Passed"
else
  echo "Test 8 Failed"
fi

echo "Test Suite Execution Completed."

