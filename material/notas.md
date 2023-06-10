# Preparação

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