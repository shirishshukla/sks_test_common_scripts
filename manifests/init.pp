#

class lfg_wh_common_scripts {

    #notice{"am here ...":}
    notify{"heree ...":}

  # Linux/AIX
  if ($::kernel == 'Linux') or ($::kernel == 'AIX') {

    $scriptdir = '/opt/was/scritps'

    realize(File['/opt/was'])

    file { $scriptdir:
      ensure  => directory,
      require => File['/opt/was']
    }
  }

  # windows 
  if ($::kernel == 'windows') {

    $scriptdir = 'E:\WHScripts'

    file { $scriptdir:
      ensure  => directory,
    }
  }

  # Do local git checkout
  if $scriptdir != undef {
    lfg_wh_common_scripts::gitpull {$scriptdir: }
  }

}
