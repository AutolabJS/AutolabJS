### Main Server ###

This Autolab component is responsible for serving the website and accepting evaluation requests from users. The main server component uses the configuration files available in `deploy/configs/main_server` directory to create necessary table entries in the MySQL DB. The main server also accesses the MySQL DB to prepare response for scoreboard requests.    
Another function of main server component is to provide web interface for configuration of an Autolab installation.
