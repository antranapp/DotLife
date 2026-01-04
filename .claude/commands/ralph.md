/ralph-wiggum:ralph-loop "Read '/Users/antran/Projects/iOS/Indie/DotLife/documents/DotLife_Moments_MVP_PRD.md' and '/Users/antran/Projects/iOS/Indie/DotLife/documents/DotLife_Technical_Design_Tuist_SPM.md' to understand the requirement. Read '/Users/antran/Projects/iOS/Indie/DotLife/.claude/task_state.txt' to get the current filename of the todo file. Read the corresponding todo file in the '/Users/antran/Projects/iOS/Indie/DotLife/documents/todo' folder. Implement all the tasks in this todo file.

CRITICAL VERIFICATION RULES:
1. For EVERY task, you must have CONCRETE EVIDENCE of completion - not just file creation.
2. If a task says 'run tests' or 'add tests', you MUST actually EXECUTE the tests and show passing output.
3. If a task says 'verify X works', you MUST run the verification command and capture the output.
4. Creating files is NOT the same as verifying they work. ALWAYS run what you create.
5. Before marking ANY acceptance criteria as done, ask yourself: 'Do I have command output proving this works?'
6. For test tasks: run `swift test`, `xcodebuild test`, `maestro test`, etc. and show the results.
7. For build tasks: show 'BUILD SUCCEEDED' output.
8. Never mark a task complete based on 'should work' - only mark complete when you SEE it work.

Iterate on the task until you have EXECUTED evidence for all acceptance criteria. Mark all tasks and acceptance criteria as done ONLY after verification. Replace the text in '/Users/antran/Projects/iOS/Indie/DotLife/.claude/task_state.txt' with the file name of the next todo file. And proceed to that file following the same workflow above. Loop until there is no more todo file to process. Output <promise>COMPLETE</promise> when done." --completion-promise "COMPLETE" --max-iterations 10 