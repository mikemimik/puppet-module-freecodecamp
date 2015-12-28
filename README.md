## FreeCodeCamp Puppet Module

### Global Variables (all optional)
- node_versoin: version of node
- home_dir: users home directory
- default_bin: default bin dirs to use
- nvm_path: path to nvm to utilize node
- default_user: default user

### Usage

```puppet
class { 'fccmodule':
  #Global varibales here
}
```
Or if no options are going to be used
```puppet
include fccmodule
```