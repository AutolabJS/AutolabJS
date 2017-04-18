### Execution Node ###
This Autolab component is responsible for executing evaluation requests from users. The execution node component uses the configuration files available in `deploy/configs/execution_nodes` directory to serve a load balancer. This component does not interact with MySQL DB.    
At present, execution noce supports evaluation in C, C++ 2011, C++ 2014, Python2, Python3 and Java programming languages. Support for more programming languages can be added by installing the respective language toolchain in the execution node.
