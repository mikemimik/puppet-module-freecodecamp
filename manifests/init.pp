class fccmodule(
  $node_version = undef,
  $home_dir     = undef,
  $default_bin  = undef,
  $nvm_path     = undef,
  $default_user = undef
) {
  $version  = pick($node_version, '4.2.2')
  $dir      = pick($home_dir, '/home/vagrant')
  $bin      = pick($default_bin, '/usr/local/bin:/usr/bin:/bin')
  $npm_path = pick($nvm_path, [
    "/usr/local/bin",
    "/usr/bin",
    "/bin",
    "${dir}/.nvm/versions/node/v${version}/bin"
  ])
  $user     = pick($default_user, 'vagrant')

  exec { 'clone_fcc':
    user    => $user,
    command => "git clone --depth=1 https://github.com/freecodecamp/freecodecamp.git freecodecamp",
    path    => $bin,
    cwd     => $dir,
    unless  => ["test -f ${dir}/freecodecamp/package.json"],
    require => [Package["git"]]
  }

  exec { 'limit_npm':
    user    => $user,
    command => "bash -c 'source ${dir}/.bashrc ; npm config set jobs 1'",
    path    => $npm_path,
    logoutput => on_failure,
    require => [Class['nodejs']]
  }

  file { 'fcc-env-file':
    path    => "${dir}/freecodecamp/.env",
    ensure  => present,
    group   => 'root',
    owner   => $user,
    source  => 'puppet:///modules/fccmodule/fcc-env-file',
    require => [Exec['clone_fcc']]
  }

  file { 'rev-manifest':
    path    => "${dir}/freecodecamp/server/rev-manifest.json",
    ensure  => present,
    group   => 'root',
    owner   => $user,
    content => "{}",
    require => [Exec['clone_fcc']]
  }

  exec { 'npm_install':
    user    => $user,
    command => "bash -c 'source ${dir}/.bashrc ; npm install'",
    path    => $npm_path,
    cwd     => "${dir}/freecodecamp",
    timeout => 0,
    require => [Class['nodejs'], Exec['limit_npm']]
  }

  exec { 'node_seed':
    user    => $user,
    command => "bash -c 'source ${dir}/.bashrc ; node seed'",
    path    => $npm_path,
    timeout => 0,
    require => [
      Class['nodejs'],
      Exec['limit_npm'],
      File['rev-manifest'],
      Exec['npm_install']
    ]
  }

  exec { 'node_seed_non-profit':
    user    => $user,
    command => "bash -c 'source ${dir}/.bashrc ; node seed/non-profit'",
    path    => $npm_path,
    timeout => 0,
    require => [
      Class['nodejs'],
      Exec['limit_npm'],
      File['rev-manifest'],
      Exec['npm_install']
    ]
  }

  # EXPERIMENTAL
  # exec { 'npm_install_bower':
  #   command => "npm install -g bower",
  #   path => ["/bin", "/usr/bin", "/usr/local/bin"],
  #   cwd => "/home/vagrant/developer/freecodecamp",
  #   user => 'root',
  #   require => [Exec["clone_fcc"]]
  # }

  # exec { 'npm_install_fcc':
  #   command => "npm --logevel=error install",
  #   path => ["/bin", "/usr/bin", "/usr/local/bin"],
  #   cwd => "/home/vagrant/developer/freecodecamp",
  #   user => 'root',
  #   require => [Exec["npm_install_bower"]]
  # }

  # exec { 'bower_install':
  #   command => "bower install --config.interactive=false",
  #   path => ["/bin", "/usr/bin", "/usr/local/bin"],
  #   cwd => "/home/vagrant/developer/freecodecamp",
  #   user => 'root',
  #   require => [Exec["npm_install_fcc"]]
  # }
}