require('mix')


function path_a_changed()
  print("pathA changed to", path_a)
end

defineParameter("path_a", nil, "untitled_a", path_a_changed)

function path_b_changed()
  print("pathB changed to", path_b)
end

defineParameter("path_b", nil, "untitled_b", path_b_changed)

defineParameter("silence_rate_percentage", nil, 0, 0.0, 1.0, 0.1) -- Silence Rate: how probable it is that a note in the matrix (piano roll representation) will be a silence
defineParameter("lower_diff_percentage", nil, 0, 0.0, 1.0, 0.01) -- bipolar parameter from 0.0 to 1.0 with 0.01 steps
defineParameter("upper_diff_percentage", nil, 0, 0.0, 1.0, 0.01) -- bipolar parameter from 0.0 to 1.0 with 0.01 steps
defineParameter("num_attempts", nil, 0, 1, 5, 1) -- bipolar parameter from 0 to 5 with steps of 1

silence_rate_percentage = 0.7
lower_diff_percentage = 0.05
upper_diff_percentage = 0.7
num_attempts = 5

function onNote(event)
  runAsync(run, path_a, path_b, silence_rate_percentage, lower_diff_percentage, upper_diff_percentage, num_attempts)
end

function run(path_a, path_b, silence_rate_percentage, lower_diff_percentage, upper_diff_percentage, num_attempts)
  midiSequenceA = readMidiFile(path_a)
  midiSequenceB = readMidiFile(path_b)
  mix(midiSequenceA, midiSequenceB, silence_rate_percentage, lower_diff_percentage, upper_diff_percentage, num_attempts)
end