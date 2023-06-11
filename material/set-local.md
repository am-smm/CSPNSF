# Laravel Localization

![Localization](https://img-9gag-fun.9cache.com/photo/aKE15w1_460s.jpg)

[Documentação oficial (LV10)](https://laravel.com/docs/10.x/localization)

[Locales and code pages](https://www.ibm.com/docs/en/radfws/9.7?topic=overview-locales-code-pages-supported)

[List of Supported Timezones](https://www.php.net/manual/en/timezones.php)

### Publishing The Language Files
```
php artisan lang:publish
```


### Create lang/pt_PT folder
```
mkdir ./lang/pt_PT
```


### Small changes to config/app.php
```

    /*
    |--------------------------------------------------------------------------
    | Application Timezone
    |--------------------------------------------------------------------------
    |
    | Here you may specify the default timezone for your application, which
    | will be used by the PHP date and date-time functions. We have gone
    | ahead and set this to a sensible default for you out of the box.
    |
    */

    'timezone' => 'Europe/Lisbon', //'UTC',

    /*
    |--------------------------------------------------------------------------
    | Application Locale Configuration
    |--------------------------------------------------------------------------
    |
    | The application locale determines the default locale that will be used
    | by the translation service provider. You are free to set this value
    | to any of the locales which will be supported by the application.
    |
    */

    'locale' => 'pt_PT', // 'en',

    /*
    |--------------------------------------------------------------------------
    | Application Fallback Locale
    |--------------------------------------------------------------------------
    |
    | The fallback locale determines the locale to use when the current one
    | is not available. You may change the value to correspond to any of
    | the language folders that are provided through your application.
    |
    */

    'fallback_locale' =>  'pt_PT', // 'en',

```


![Read the docs](https://img.devrant.com/devrant/rant/r_1096632_Zk451.jpg)


![Read the docs](https://img.ifunny.co/images/40e231355904175506984ead1a78f6601963ce39262b68fd596d6f4b59a36b80_1.webp)


![Read the docs](https://pbs.twimg.com/media/FEAJJSnXEAEBpWd?format=png&name=small)

