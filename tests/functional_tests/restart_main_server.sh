<<<<<<< HEAD
#!/bin/sh
=======
>>>>>>> add5881... scoreboard tests
kill $(lsof -t -i:9000)
cd ../../main_server
nohup node main_server.js &