# Conf module | [![build status](https://gitlab.com/space-sh/conf/badges/master/pipeline.svg)](https://gitlab.com/space-sh/conf/commits/master)


# Functions 

## CONF\_READ()  
  
  
  
Read and parse a conf file.  
  
The conf file should look like:  
```  
name    Giganticus  
animal  Octopus (Enteroctopus membranaceus)  
Comments on separate lines are OK.  
name    Astro Chicken  
animal  Chicken (Gallus gallus)  
```  
  
It will stop reading when an already set variable is encountered again, this is the signal that conf has read "one block".  
  
$out\_conf\_lineno will be updated so the next time you call CONF\_READ you will get the next "block".  
Remember to reset all variables first, otherwise it won't read new lines.  
$out\_conf\_lineno will be set to -1 when no more lines could be read.  
  
### Example:  
` local out_conf_lineno0   Only done once. `  
` local name `  
` local animal `  
` CONF_READ "/tmp/my.conf" "name animal" `  
` echo "${name} is a ${animal}." `  
  
` Read next block `  
` local name `  
` local animal `  
` CONF_READ "/tmp/my.conf" "name animal" `  
` echo "${name} is a ${animal}." `  
  
### Parameters:  
- $1: file path  
- $2: variable names allowed  
  
### Expects:  
- $out\_conf\_lineno: should have been declared  0.  
- $keys: Variable names defined in $2 should prior have been initialized and set to empty, like "local name".  
  
### Returns:  
- 0: success  
- 1: failure  
  
  
  
