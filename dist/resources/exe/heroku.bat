:: Don't use ECHO OFF to avoid possible change of ECHO
:: Use SETLOCAL so variables set in the script are not persisted
@SETLOCAL

:: Add bundled ruby version to the PATH, use NuvadoPath as starting point
@SET NUVADO_RUBY="%HerokuPath%\ruby-1.9.2\bin"
@SET PATH=%NUVADO_RUBY%;%PATH%

:: Invoke 'nuvado' (the calling script) as argument to ruby.
:: Also forward all the arguments provided to it.
@ruby.exe "%~dpn0" %*
