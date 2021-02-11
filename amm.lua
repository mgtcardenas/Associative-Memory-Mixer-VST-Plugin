require('mix')

function pathAChanged()
  print("pathA changed to", pathA)
end

defineParameter("pathA", nil, "untitledA", pathAChanged)

function pathBChanged()
  print("pathB changed to", pathB)
end

defineParameter("pathB", nil, "untitledB", pathBChanged)

defineParameter("silence_rate_percentage", nil, 0, 0.0, 1.0, 0.1) -- bipolar parameter from 0.0 to 1.0 with 0.1 steps
defineParameter("lower_diff_percentage", nil, 0, 0.0, 1.0, 0.01) -- bipolar parameter from 0.0 to 1.0 with 0.01 steps
defineParameter("upper_diff_percentage", nil, 0, 0.0, 1.0, 0.01) -- bipolar parameter from 0.0 to 1.0 with 0.01 steps
defineParameter("num_attempts", nil, 0, 1, 5, 1) -- bipolar parameter from 0 to 5 with steps of 1

function onNote(event)
  print("Silence Rate: " .. silence_rate_percentage)
  print("Lower Diff Percentage: " .. lower_diff_percentage)
  print("Upper Diff Percentage: " .. upper_diff_percentage)
  print("Num Attempts: " .. num_attempts)
  --  runAsync(run, pathA, pathB)
end

function run(rutaA, rutaB)
  midiSequenceA = readMidiFile(rutaA)
  midiSequenceB = readMidiFile(rutaB)
  mix(midiSequenceA, midiSequenceB)
end