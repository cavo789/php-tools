# PHP-TOOLS

![Banner](./banner.svg)

The idea of these scripts are simple: industrialize certain actions such as the execution of phpunit.

* [How to install?](#how-to-install)
* [Scripts](#scripts)
  * [phpunit](#phpunit)

## How to install?

Download a copy of this repository and make sure to add the target folder to your `PATH` environment variable. So, whatever the active folder, you only have to indicate the name of the script you want to run e.g. `phpunit` for it to be executed.

## Scripts

### phpunit

> [https://github.com/sebastianbergmann/phpunit](https://github.com/sebastianbergmann/phpunit)

* Did you have phpunit installed locally or global?
* Did you have a phpunit.xml configuration file?

Don't worry about it anymore. Just start `phpunit` in a DOS prompt and the `phpunit.ps1` script will make things happens.

That script will locate with phpunit binary to use (local or global) and will retrieve the path to your `phpunit.xml` file. 

You just need (but not forced) to tell which folder / file has to be fired. For instance, run all `tests` (default) or just the `tests\api` folder or just a specified file.

```bash
phpunit tests
phpunit tests\api
phpunit tests\webservices\consume.php
```

Note: the `phpunit.xml` file will be first searched in the `.config` sub-folder of the current project. If the file doesn't exists there, the file will be searched in the root folder of the project. If no file are found, phpunit will be started without configuration file.
