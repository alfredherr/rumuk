REM -- In new console window
set PORT=4001
iex --name n2@127.0.0.1 --erl "-config sys.config" -S mix phoenix.server
