# Preparação

![let's do this!](https://www.idlememe.com/wp-content/uploads/2021/10/lets-do-this-meme-idlememe-7-300x249.jpg)


## Instalar o Laravel
```
composer create-project laravel/laravel cspnsf.src
```


## Teste da instalação
```
php artisan serve
```

## Criação da BD
```
CREATE DATABASE `smm_jardinf` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
```


## Configuração da BD no ficheiro .env
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1   
DB_PORT=3306   
DB_DATABASE=smm_jardinf  
DB_USERNAME=root 
DB_PASSWORD=  
```
---

## Instalação do nodeJS (para quem não tiver...)
[url: node](https://nodejs.org/en/download)
Instalar no Windows recorrendo ao instalador.

**MAC users**: 
Usar [homebrew](https://formulae.brew.sh/formula/node)!


## Instalação do MailHog
[url: github Guide](https://github.com/mailhog/MailHog)

[url: Step-by-Step Guide](https://kinsta.com/blog/mailhog/)

Instalar no Windows recorrendo ao instalador.

**MAC users**: 
Usar [homebrew](https://formulae.brew.sh/formula/mailhog)!

```
brew install mailhog
brew services start mailhog
```


## Configuração do MailHog no ficheiro .env
```
MAIL_MAILER=smtp
MAIL_HOST=localhost
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=no-reply@whatever.dev
MAIL_FROM_NAME="${APP_NAME}"
```

---
## Configuração do Laravel Breeze
[url: Laravel Breeze](https://laravel.com/docs/10.x/starter-kits#laravel-breeze
)
```
composer require laravel/breeze --dev

php artisan breeze:install --dark
 
php artisan migrate
npm install
npm run dev
```
---
👌 done!
---
testar com:
```
php artisan serve
--> http://localhost:8000
```

---

---
## Configuração do package IDE Helper Generator
[Github: IDE Helper Generator](https://github.com/barryvdh/laravel-ide-helper)
```
composer require --dev barryvdh/laravel-ide-helper

php artisan clear-compiled
php artisan ide-helper:generate

```

### Atualizar o ficheiro composer.json
```
 "scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi",
            "@php artisan ide-helper:generate",
            "@php artisan ide-helper:meta"
        ],
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force",
            "@php artisan ide-helper:generate",
            "@php artisan ide-helper:meta"
        ],
        ...
    }
```

---
## Configuração do package Laravel-Modules
[Github: Laravel-Modules](https://github.com/nWidart/laravel-modules)
```
composer require nwidart/laravel-modules

php artisan vendor:publish --provider="Nwidart\Modules\LaravelModulesServiceProvider"
```

### Atualizar o ficheiro composer.json
```
 ...
  "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Modules\\": "Modules/",
           ...
         }
    },
 ...
```


// to install //
"barryvdh/laravel-dompdf"
"intervention/image"
"spatie/laravel-permission"