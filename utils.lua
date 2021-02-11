-- [[ Calculates the outer product of two vectors --]]
function outerproduct(u, v)
  result = {}
  for i = 1, #u, 1 do
    subresult = {}
    for j = 1, #v, 1 do
      subresult[j] = u[i] * v[j]
    end -- for - j
    result[i] = subresult
  end -- for - i
  return result
end

--[[ Prints a 2 dimensional matrix in a pretty format.
I have not discovered how to use the print function without printing a new line at the end.
That is why I use a temporary variable to store the row information --]]
function printTwoDMatrix(m)
  local tmpRow
  for i = 1, #m, 1 do
    tmpRow = ""
    for j = 1, #m[i], 1 do
      tmpRow = tmpRow .. string.format("% 06.3f ", m[i][j])
    end -- for - j
    print(tmpRow)
  end -- for - i
end

--[[ Generates a table of size n full of -1s --]]
function get_table_full_of_minus_ones(n)
  result = {}
  for i = 1, n, 1 do
    result[i] = -1
  end -- for - i
  return result
end

--[[ Bipolar step activation function applied to all the elements of an array/table/vector.
This particular implementation returns a new array/table/vector with only 1s and -1s. --]]
function vectorized_bipolar_step(v)
  result = {}
  for i = 1, #v, 1 do
    if v[i] >= 0 then
      result[i] = 1
    else
      result[i] = -1
    end -- if - else
  end --for - i
  return result
end

--[[ Function that multiplies a vector 'v' and a matrix 'm'. 
This method assumes that the vector 'v' has as many elements as 'm' has rows, allowing for correct multiplication.
A new array with the results is returned. --]]
function vector_matrix_dot_product(v, m)
  result = {}
  for j = 1, #m[1], 1 do
    tmp = 0
    for i = 1, #m, 1 do
      tmp = tmp + (v[i] * m[i][j])
    end -- for - j
    result[j] = tmp
  end -- for
  return result
end

--[[ Function that returns the square identity matrix given a size of n elements --]]
function get_identity_matrix(n)
  result = {}
  for i = 1, n, 1 do
    tmp = {}
    for j = 1, n, 1 do
      if i == j then
        tmp[j] = 1
      else
        tmp[j] = 0
      end -- if - else
    end -- for - j
    result[i] = tmp
  end -- for - i
  return result
end

--[[ Function that multiplies a matrix by a simple scalar,
i.e. it multiplies each of the elements of the matrix by that scalar.
This function returns a new matrix so as to leave the original matrix alone to avoid logical bugs. --]]
function matrix_scalar_dot_product(m, s)
  result = {}
  for i = 1, #m, 1 do
    tmp = {}
    for j = 1, #m[i], 1 do
      tmp[j] = m[i][j] * s
    end -- for - j
    result[i] = tmp
  end -- for - i
  return result
end

--[[ Function that adds matrix m1 and matrix m2 together.
This function returns a new matrix so as to leave the original matrix alone to avoid logical bugs.
It is assumed that both matrices have the same size of 'm' rows and 'n' columns. --]]
function add_matrices(m1, m2)
  result = {}
  for i = 1, #m1, 1 do
    tmp = {}
    for j = 1, #m1[1], 1 do
      tmp[j] = m1[i][j] + m2[i][j]
    end -- for - j
    result[i] = tmp
  end -- for - i
  return result
end

--[[ Function that subtracts matrix m2 from matrix m1.
This function returns a new matrix so as to leave the original matrix alone to avoid logical bugs.
It is assumed that both matrices have the same size of 'm' rows and 'n' columns. --]]
function subtract_matrices(m1, m2)
  result = {}
  for i = 1, #m1, 1 do
    tmp = {}
    for j = 1, #m1[1], 1 do
      tmp[j] = m1[i][j] - m2[i][j]
    end -- for - j
    result[i] = tmp
  end -- for - i
  return result
end

--[[ Function that returns a valid random input given the size of the samples.
It should also be given a silence rate (sr) value, i.e. the probability that a note will be a silence.--]]
function get_random_input(n, sr)
  random_input = {}
  for i = 1, n, 1 do
    if (math.random() > sr) then
      random_input[i] = 1
    else
      random_input[i] = -1
    end
  end -- for - i
  return random_input
end

--[[ Function that measures how many elements two binary vectors do not have in common.
These vectors must be represented by 1s and -1s and be of the same size. --]]
function calculate_binary_difference(u, v)
  sum = 0
  for i = 1, #u, 1 do
    sum = sum + math.abs(u[i] - v[i])
  end -- for - i
  return sum / 2
end