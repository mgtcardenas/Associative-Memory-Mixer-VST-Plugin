require('mix')

function pathAChanged()
  print("pathA changed to", pathA)
end

defineParameter("pathA", nil, "untitledA", pathAChanged)

function pathBChanged()
  print("pathB changed to", pathB)
end

defineParameter("pathB", nil, "untitledB", pathBChanged)

defineParameter("silence_rate_percentage", nil, 0, 0.0, 1.0, 0.1) -- Silence Rate: how probable it is that a note in the matrix (piano roll representation) will be a silence
defineParameter("lower_diff_percentage", nil, 0, 0.0, 1.0, 0.01) -- bipolar parameter from 0.0 to 1.0 with 0.01 steps
defineParameter("upper_diff_percentage", nil, 0, 0.0, 1.0, 0.01) -- bipolar parameter from 0.0 to 1.0 with 0.01 steps
defineParameter("num_attempts", nil, 0, 1, 5, 1) -- bipolar parameter from 0 to 5 with steps of 1

function onNote(event)
  runAsync(run, pathA, pathB, silence_rate_percentage, lower_diff_percentage, upper_diff_percentage, num_attempts)
end

function run(pathA, pathB, silence_rate_percentage, lower_diff_percentage, upper_diff_percentage, num_attempts)
  midiSequenceA = readMidiFile(pathA)
  midiSequenceB = readMidiFile(pathB)
  mix(midiSequenceA, midiSequenceB, silence_rate_percentage, lower_diff_percentage, upper_diff_percentage, num_attempts)
end