// Cookie listing based on a manual cookie audit perfomed at 2025-02-24 on
// OmaStadi production site.
//
// In order to modify these settings, you can modify the settings by hand or
// generate the JSON at:
// https://hds.hel.fi/storybook/react/static-cookie-consent-editor/siteSettingsEditor.html

const CURRENT_HOST = window.location.hostname;

export default {
  "languages": [
    {
      "code": "fi",
      "name": "Finnish",
      "direction": "ltr"
    },
    {
      "code": "sv",
      "name": "Swedish",
      "direction": "ltr"
    },
    {
      "code": "en",
      "name": "English",
      "direction": "ltr"
    }
  ],
  "siteName": {
    "fi": "OmaStadi",
    "sv": "VårStad",
    "en": "OmaStadi"
  },
  "cookieName": "decidim-consent",
  "monitorInterval": 500,
  "fallbackLanguage": "en",
  "requiredGroups": [
    {
      "groupId": "essential",
      "title": {
        "fi": "Välttämättömät toiminnalliset evästeet",
        "sv": "Nödvändiga funktionella cookies",
        "en": "Essential cookies"
      },
      "description": {
        "fi": "Välttämättömät evästeet auttavat tekemään verkkosivustosta käyttökelpoisen sallimalla perustoimintoja, kuten sivulla siirtymisen ja sivuston suojattujen alueiden käytön. Verkkosivusto ei toimi kunnolla ilman näitä evästeitä eikä niihin tarvita suostumusta.",
        "sv": "Nödvändiga cookies hjälper till att göra webbplatsen användbar genom att tillåta grundläggande funktioner som att navigera på sidan och använda de skyddade områdena på webbplatsen. Webbplatsen fungerar inte korrekt utan dessa cookies och kräver inte samtycke.",
        "en": "Essential cookies help to make the website usable by allowing basic functions, navigating the page and using the protected areas of the site. The website will not work properly without these cookies and their consent is not required."
      },
      "cookies": [
        {
          "name": "_session_id",
          "host": CURRENT_HOST,
          "storageType": 1,
          "description": {
            "fi": "Vierailijan istuntotieto sivustolla, joka tallentaa mm. tiedon kirjautuneesta käyttäjästä.",
            "sv": "Besökssessionsinformation på webbplatsen, som lagrar t.ex. information om den inloggade användaren.",
            "en": "Visitor's session information on the site, which stores, e.g., information about the logged-in user."
          },
          "expiration": {
            "fi": "Istunto tai 30 minuuttia inaktiivisena",
            "sv": "30 minuter vid inaktiv",
            "en": "Istunto or 30 minutes when inactive"
          }
        },
        {
          "name": "decidim-consent",
          "host": CURRENT_HOST,
          "storageType": 1,
          "description": {
            "fi": "Eväste tallentaa tiedon siitä, ovatko kävijät antaneet hyväksyntänsä tai kieltäytyneet evästeiden käytöstä.	",
            "sv": "Lagrar information om besökaren har gett sitt samtycke eller avböjt användningen av cookies som används på webbplatsen.",
            "en": "Stores information whether the visitor has given their consent or declined the use of cookies used on the website."
          },
          "expiration": {
            "fi": "100 päivää",
            "sv": "100 dagar",
            "en": "100 days"
          }
        }
      ]
    }
  ],
  "optionalGroups": [
    {
      "groupId": "preferences",
      "title": {
        "fi": "Personointi",
        "sv": "Preferens",
        "en": "Preference"
      },
      "description": {
        "fi": "Mieltymysevästeet mukauttavat sivuston ulkoasua ja toimintaa käyttäjän aiemman käytön perusteella.",
        "sv": "Preferenscookies ändrar webbplatsens utseende och funktioner enligt användarens tidigare användning.",
        "en": "Preference cookies modify the visuals and functions of the website based on the user's previous sessions."
      },
      "cookies": [
        {
          "name": "JSESSIONID",
          "host": "helsinkikanava.fi / suite.icareus.com",
          "storageType": 1,
          "description": {
            "fi": "Helsinki-kanava -sivuston pakollinen eväste mahdollistaa kävijän vierailun sivustolla.",
            "sv": "Helsingforskanalens cookie är en obligatorisk cookie som gör det möjligt för besökaren att besöka webbplatsen.",
            "en": "The Helsinki Channel cookie is an obligatory cookie that facilitates visiting the website."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "COOKIE_SUPPORT",
          "host": "helsinkikanava.fi / suite.icareus.com",
          "storageType": 1,
          "description": {
            "fi": "Helsinki-kanava -palvelun eväste, joka mahdollistaa evästeiden hallinnan Helsinki-kanava sivustolla.",
            "sv": "Helsingforskanalens cookie möjliggör hanteringen av cookies på webbplatsen.",
            "en": "The Helsinki Channel cookie facilitates managing cookies on the website."
          },
          "expiration": {
            "fi": "365 päivää",
            "sv": "365 dagar",
            "en": "365 days"
          }
        },
        {
          "name": "icareusDevice",
          "host": "helsinkikanava.fi / suite.icareus.com",
          "storageType": 2,
          "description": {
            "fi": "Helsinki-kanavan videopalvelimen tietue, joka helpottaa videoiden liittämistä osaksi sivuston sisältöä.",
            "sv": "Helsingforskanalens videoserverinformation som underlättar att inkludera videor som en del av webbplatsens innehåll.",
            "en": "The Helsinki Channel video server information that facilitates including videos as part of the website's content."
          },
          "expiration": "-"
        },
        {
          "name": "rmpVolume",
          "host": "helsinkikanava.fi / suite.icareus.com",
          "storageType": 2,
          "description": {
            "fi": "Helsinki-kanavan videopalvelimen tietue, joka tallentaa tiedon vierailijan äänenvoimakkuudesta kyseisen palvelun videoissa.",
            "sv": "Helsingforskanalens videoserverinformation som lagrar besökarens ljudvolyminformation i videorna som tillhandahålls av denna tjänst.",
            "en": "The Helsinki Channel video server information that stores the visitor's sound volume information within the videos provided by this service."
          },
          "expiration": "-"
        },
        {
          "name": "VISITOR_PRIVACY_METADATA",
          "host": "youtube.com",
          "storageType": 1,
          "description": {
            "fi": "YouTuben eväste tallentaa evästehyväksynnän tilan YouTube-palvelussa.",
            "sv": "YouTube-cookien lagrar samtyckesvalet för cookie på YouTube.",
            "en": "The YouTube cookie stores the cookie consent choise on YouTube."
          },
          "expiration": {
            "fi": "180 päivää",
            "sv": "180 dagar",
            "en": "180 days"
          }
        },
        {
          "name": "__Secure-ROLLOUT_TOKEN",
          "host": "youtube.com",
          "storageType": 1,
          "description": {
            "fi": "YouTuben eväste, jonka avulla hallinnoidaan uusien ominaisuuksien ja päivitysten asteittaista käyttöönottoa YouTubessa.",
            "sv": "YouTube-cookien används för att hantera gradvis lansering av nya funktioner och uppdateringar på YouTube.",
            "en": "The YouTube cookie is used for managing phased rollout of new features and updates on YouTube."
          },
          "expiration": {
            "fi": "180 päivää",
            "sv": "180 dagar",
            "en": "180 days"
          }
        },
        {
          "name": "AEC",
          "host": "youtube.com",
          "storageType": 1,
          "description": {
            "fi": "YouTuben eväste tunnistaa roskapostittajia, petoksia tai palvelun väärinkäyttöä YouTube-videosisältöjen käytössä.",
            "sv": "YouTube-cookien upptäcker spam, bedrägerier eller missbruk i YouTube-videorna.",
            "en": "The YouTube cookie detects spam, fraud or abuse within the YouTube videos."
          },
          "expiration": {
            "fi": "180 päivää",
            "sv": "180 dagar",
            "en": "180 days"
          }
        },
        {
          "name": "SOCS",
          "host": "youtube.com",
          "storageType": 1,
          "description": {
            "fi": "YouTuben eväste tallentaa evästehyväksynnän tilan YouTube-palvelussa.",
            "sv": "YouTube-cookien lagrar samtyckesvalet för cookie på YouTube.",
            "en": "The YouTube cookie stores the cookie consent choise on YouTube."
          },
          "expiration": {
            "fi": "395 päivää",
            "sv": "395 dagar",
            "en": "395 days"
          }
        },
        {
          "name": "yt-html5-player-modules::subtitlesModuleData::module-enabled",
          "host": "youtube.com",
          "storageType": 2,
          "description": {
            "fi": "Tallentaa tiedon, onko vierailija ottanut tekstitykset käyttöön YouTube-videoissa.",
            "sv": "Lagrar information om besökaren har aktiverat undertexter på YouTube-videor.",
            "en": "Stores information whether the visitor has enabled subtitles on YouTube videos."
          },
          "expiration": "-"
        },
        {
          "name": "yt-player-bandwidth",
          "host": "youtube.com",
          "storageType": 2,
          "description": {
            "fi": "Tallentaa tietoa käyttäjän internet-yhteyden nopeudesta YouTube-videoissa.",
            "sv": "Lagrar information om besökarens internetuppkopplingshastighet för YouTube-videor.",
            "en": "Stores information about the visitor's internet connection speed for YouTube videos."
          },
          "expiration": "-"
        },
        {
          "name": "yt-player-headers-readable",
          "host": "youtube.com",
          "storageType": 2,
          "description": {
            "fi": "Käytetään videolaadun optimoimiseen YouTube-videoissa vierailijan laitteen ja verkkoyhteyden perusteella.",
            "sv": "Används för att bestämma den optimala YouTube-videokvaliteten baserat på besökarens enhet och nätverksinställningar.",
            "en": "Used to determine the optimal YouTube video quality based on the visitor's device and network settings."
          },
          "expiration": "-"
        },
        {
          "name": "yt-player-volume",
          "host": "youtube.com",
          "storageType": 2,
          "description": {
            "fi": "Tallentaa tiedon vierailijan äänenvoimakkuudesta YouTube-videoissa.",
            "sv": "Lagrar information om besökarens ljudvolym för YouTube-videor.",
            "en": "Stores information about the visitor's sound volume for YouTube videos."
          },
          "expiration": "-"
        },
        {
          "name": "yt-remote-connected-devices",
          "host": "youtube.com",
          "storageType": 2,
          "description": {
            "fi": "Tallentaa tiedon vierailijan YouTubeen liitetyistä etälaitteista.",
            "sv": "Lagrar information om besökarens fjärrenheter som är anslutna till YouTube.",
            "en": "Stores information about the visitor's remote devices connected to YouTube."
          },
          "expiration": "-"
        },
        {
          "name": "yt-remote-device-id",
          "host": "youtube.com",
          "storageType": 2,
          "description": {
            "fi": "YouTuben yksilöivä tunniste etälaitteelle.",
            "sv": "Unik identifierare för en fjärrenhet på YouTube.",
            "en": "Unique identifier of a remote device at YouTube."
          },
          "expiration": "-"
        },
        {
          "name": "ytidb::LAST_RESULT_ENTRY_KEY",
          "host": "youtube.com",
          "storageType": 2,
          "description": {
            "fi": "YouTuben videotoistoon liittyvä tietue.",
            "sv": "Information för YouTube-videouppspelning.",
            "en": "Information for YouTube video playback."
          },
          "expiration": "-"
        },
        {
          "name": "yt-player-caption-language-preferences",
          "host": "youtube.com",
          "storageType": 3,
          "description": {
            "fi": "Tallentaa tiedon vierailijan kielivalinnasta YouTube-videoiden tekstityksille.",
            "sv": "Lagrar information om besökarens språkpreferens för YouTube-videoundertexter.",
            "en": "Stores information about the visitor's language preference for YouTube video subtitles."
          },
          "expiration": "-"
        },
        {
          "name": "yt-remote-cast-available",
          "host": "youtube.com",
          "storageType": 3,
          "description": {
            "fi": "Tallentaa tiedon, onko vierailijalla mahdollisuutta YouTube-videoiden etätoistolle.",
            "sv": "Lagrar information om huruvida besökaren har möjlighet att skicka på distans för YouTube-videor.",
            "en": "Stores information whether the visitor has remote cast possibility for YouTube videos."
          },
          "expiration": "-"
        },
        {
          "name": "yt-remote-cast-installed",
          "host": "youtube.com",
          "storageType": 3,
          "description": {
            "fi": "Tallentaa tiedon, onko vierailija asentanut YouTube-videoiden etätoiston.",
            "sv": "Lagrar information om besökaren har installerat fjärrcast för YouTube-videor.",
            "en": "Stores information whether the visitor has installed remote cast for YouTube videos."
          },
          "expiration": "-"
        },
        {
          "name": "yt-remote-fast-check-period",
          "host": "youtube.com",
          "storageType": 3,
          "description": {
            "fi": "YouTuben videotoistoon liittyvä tietue.",
            "sv": "Information för YouTube-videouppspelning.",
            "en": "Information for YouTube video playback."
          },
          "expiration": "-"
        },
        {
          "name": "yt-remote-session-app",
          "host": "youtube.com",
          "storageType": 3,
          "description": {
            "fi": "YouTuben videotoistoon liittyvä tietue.",
            "sv": "Information för YouTube-videouppspelning.",
            "en": "Information for YouTube video playback."
          },
          "expiration": "-"
        },
        {
          "name": "yt-remote-session-name",
          "host": "youtube.com",
          "storageType": 3,
          "description": {
            "fi": "YouTuben videotoistoon liittyvä tietue.",
            "sv": "Information för YouTube-videouppspelning.",
            "en": "Information for YouTube video playback."
          },
          "expiration": "-"
        },
        {
          "name": "LogsDatabaseV2:*",
          "host": "youtube.com",
          "storageType": 4,
          "description": {
            "fi": "YouTube-videopalvelun lokitietokanta.",
            "sv": "Loggdatabas för YouTube-videotjänst.",
            "en": "Log database for YouTube video service."
          },
          "expiration": "-"
        },
        {
          "name": "ServiceWorkerLogsDatabase",
          "host": "youtube.com",
          "storageType": 4,
          "description": {
            "fi": "YouTube-videopalvelun lokitietokanta.",
            "sv": "Loggdatabas för YouTube-videotjänst.",
            "en": "Log database for YouTube video service."
          },
          "expiration": "-"
        },
        {
          "name": "graphiql:tabState",
          "host": CURRENT_HOST,
          "storageType": 2,
          "description": {
            "fi": "Tallentaa GraphQL-rajapintaeditorin välilehtiasetukset",
            "sv": "Lagrar flikkonfigurationen för GraphQL API-redigeraren",
            "en": "Stores the tab configuration for the GraphQL API editor"
          },
          "expiration": "-"
        },
        {
          "name": "graphiql:query",
          "host": CURRENT_HOST,
          "storageType": 2,
          "description": {
            "fi": "Tallentaa GraphQL-rajapintaeditorin viimeisimmän kyselyn",
            "sv": "Lagrar den senaste frågan för GraphQL API-redigeraren",
            "en": "Stores the last query for the GraphQL API editor"
          },
          "expiration": "-"
        },
        {
          "name": "graphiql:docExplorerOpen",
          "host": CURRENT_HOST,
          "storageType": 2,
          "description": {
            "fi": "Tallentaa GraphQL-rajapintaeditorille tiedon siitä, onko dokumentaatiovälilehti auki vai ei",
            "sv": "Lagrar en konfiguration för GraphQL API-redigeraren som anger om dokumentationspanelen är öppen eller inte",
            "en": "Stores a configuration for the GraphQL API editor indicating whether the documentation panel is open or not"
          },
          "expiration": "-"
        },
        {
          "name": "graphiql:queries",
          "host": CURRENT_HOST,
          "storageType": 2,
          "description": {
            "fi": "Tallentaa GraphQL-rajapintaeditorin kyselyhistorian",
            "sv": "Lagrar frågehistoriken i GraphQL API-redigeraren",
            "en": "Stores the query history within the GraphQL API editor"
          },
          "expiration": "-"
        },
        {
          "name": "graphiql:shouldPersistHeaders",
          "host": CURRENT_HOST,
          "storageType": 2,
          "description": {
            "fi": "Tallentaa GraphQL-rajapintaeditorille tiedon siitä, halutaanko kyselyjen otsaketiedot kiinnittää uusille kyselyille",
            "sv": "Lagrar en konfiguration för GraphQL API-redigeraren som anger om rubrikinformationen ska finnas kvar för följande frågor",
            "en": "Stores a configuration for the GraphQL API editor indicating whether the header information should be persisted for following queries"
          },
          "expiration": "-"
        },
      ]
    },
    {
      "groupId": "statistics",
      "title": {
        "fi": "Tilastointi",
        "sv": "Statistik",
        "en": "Statistics"
      },
      "description": {
        "fi": "Tilastointievästeiden keräämää tietoa käytetään verkkosivuston kehittämiseen.",
        "sv": "De uppgifter statistikcookies samlar in används för att utveckla webbplatsen.",
        "en": "The information collected by statistics cookies is used for developing the website."
      },
      "cookies": [
        {
          "name": "VISITOR_INFO1_LIVE",
          "host": "youtube.com",
          "storageType": 1,
          "description": {
            "fi": "YouTuben eväste valitsee yhteyden nopeuden mukaan, joko vanhan tai uuden videosoittimen.",
            "sv": "YouTube-cookien väljer den gamla eller nya videospelaren beroende på anslutningshastigheten.",
            "en": "The YouTube cookie selects the old or new video player depending on the connection speed."
          },
          "expiration": {
            "fi": "180 päivää",
            "sv": "180 dagar",
            "en": "180 days"
          }
        },
        {
          "name": "YSC",
          "host": "youtube.com",
          "storageType": 1,
          "description": {
            "fi": "YouTuben eväste tallentaa käyttäjän yksilöivän tunnisteen, joka todentaa pyyntöjen tulevan samasta selainistunnosta.",
            "sv": "YouTube-cookien lagrar ett unikt ID för användarna för att säkerställa att förfrågningar inom en surfsession görs av samma användare.",
            "en": "The YouTube cookie stores a unique ID for the users to ensure that requests within a browsing session are made by the same user."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "__Secure-ENID",
          "host": "youtube.com",
          "storageType": 1,
          "description": {
            "fi": "YouTuben eväste analytiikkatarkoituksiin YouTube-videoissa.",
            "sv": "YouTube-cookien för analytiska ändamål i YouTube-videorna.",
            "en": "The YouTube cookie for analytical purposes within the YouTube videos."
          },
          "expiration": {
            "fi": "180 päivää",
            "sv": "180 dagar",
            "en": "180 days"
          }
        },
        {
          "name": "SID",
          "host": "youtube.com, google.com",
          "storageType": 1,
          "description": {
            "fi": "Googlen eväste, joka tallentaa digitaalisesti allekirjoitetun tiedon käyttäjän Google ID:stä viimeisimmän kirjautumisen aikaan.",
            "sv": "Googles cookie som lagrar digitalt signerad information om användarens Google-ID vid tidpunkten för sin senaste inloggning.",
            "en": "Google's cookie that stores digitally signed information about the user's Google ID at the time of their last login."
          },
          "expiration": {
            "fi": "730 päivää",
            "sv": "730 dagar",
            "en": "730 days"
          }
        },
        {
          "name": "HSID",
          "host": "youtube.com, google.com",
          "storageType": 1,
          "description": {
            "fi": "Googlen eväste, joka tallentaa digitaalisesti allekirjoitetun tiedon käyttäjän Google ID:stä viimeisimmän kirjautumisen aikaan.",
            "sv": "Googles cookie som lagrar digitalt signerad information om användarens Google-ID vid tidpunkten för sin senaste inloggning.",
            "en": "Google's cookie that stores digitally signed information about the user's Google ID at the time of their last login."
          },
          "expiration": {
            "fi": "730 päivää",
            "sv": "730 dagar",
            "en": "730 days"
          }
        },
        {
          "name": "YtIdbMeta",
          "host": "youtube.com",
          "storageType": 4,
          "description": {
            "fi": "Tallentaa tietoa vierailijan suorittamista toimista YouTube-videopalvelussa.",
            "sv": "Lagrar information om besökarens interaktion med inbäddat YouTube-videoinnehåll.",
            "en": "Stores information about the visitor's interaction with embedded YouTube video content."
          },
          "expiration": "-"
        },
      ]
    },
    {
      "groupId": "marketing",
      "title": {
        "fi": "Markkinointi",
        "sv": "Marknadsföring",
        "en": "Marketing"
      },
      "description": {
        "fi": "Markkinointievästeitä käytetään mainonnan kohdistamiseen ja toimittamiseen.",
        "sv": "Marknadsföringscookies används för att rikta och leverera reklam.",
        "en": "Marketing cookies are used to target and deliver advertising."
      },
      "cookies": [
        {
          "name": "DV",
          "host": "youtube.com",
          "storageType": 1,
          "description": {
            "fi": "YouTuben eväste mainonnan kohdistamiseen ja toimittamiseen.",
            "sv": "YouTube-cookien för inriktning och leverans av annonser.",
            "en": "The YouTube cookie for targeting and delivering advertisements."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "NID",
          "host": "youtube.com",
          "storageType": 1,
          "description": {
            "fi": "YouTuben eväste analytiikka- ja mainostustarkoituksiin YouTube-videoissa.",
            "sv": "YouTube-cookien för analytiska och reklamändamål i YouTube-videorna.",
            "en": "The YouTube cookie for analytical and advertisement purposes within the YouTube videos."
          },
          "expiration": {
            "fi": "180 päivää",
            "sv": "180 dagar",
            "en": "180 days"
          }
        },
        {
          "name": "APISID",
          "host": "youtube.com, google.com",
          "storageType": 1,
          "description": {
            "fi": "Googlen eväste, jota hyödynnetään personoidun sisällön näyttämiseen Googlen palveluissa.",
            "sv": "Googles cookie som tillhandahåller visning av personligt innehåll på Googles tjänster.",
            "en": "Google's cookie that provides displaying personalized content on Google services."
          },
          "expiration": {
            "fi": "730 päivää",
            "sv": "730 dagar",
            "en": "730 days"
          }
        },
        {
          "name": "__Secure-*PAPISID",
          "host": "youtube.com, google.com",
          "storageType": 1,
          "description": {
            "fi": "Googlen eväste, jota hyödynnetään personoidun sisällön näyttämiseen Googlen palveluissa.",
            "sv": "Googles cookie som tillhandahåller visning av personligt innehåll på Googles tjänster.",
            "en": "Google's cookie that provides displaying personalized content on Google services."
          },
          "expiration": {
            "fi": "730 päivää",
            "sv": "730 dagar",
            "en": "730 days"
          }
        },
        {
          "name": "__Secure-*PSID",
          "host": "youtube.com, google.com",
          "storageType": 1,
          "description": {
            "fi": "Googlen eväste, jota hyödynnetään personoidun sisällön näyttämiseen Googlen palveluissa.",
            "sv": "Googles cookie som tillhandahåller visning av personligt innehåll på Googles tjänster.",
            "en": "Google's cookie that provides displaying personalized content on Google services."
          },
          "expiration": {
            "fi": "730 päivää",
            "sv": "730 dagar",
            "en": "730 days"
          }
        },
        {
          "name": "__Secure-*PSIDCC",
          "host": "youtube.com, google.com",
          "storageType": 1,
          "description": {
            "fi": "Googlen eväste, jota hyödynnetään personoidun sisällön näyttämiseen Googlen palveluissa.",
            "sv": "Googles cookie som tillhandahåller visning av personligt innehåll på Googles tjänster.",
            "en": "Google's cookie that provides displaying personalized content on Google services."
          },
          "expiration": {
            "fi": "730 päivää",
            "sv": "730 dagar",
            "en": "730 days"
          }
        },
        {
          "name": "__Secure-*PSIDTS",
          "host": "youtube.com, google.com",
          "storageType": 1,
          "description": {
            "fi": "Googlen eväste, jota hyödynnetään personoidun sisällön näyttämiseen Googlen palveluissa.",
            "sv": "Googles cookie som tillhandahåller visning av personligt innehåll på Googles tjänster.",
            "en": "Google's cookie that provides displaying personalized content on Google services."
          },
          "expiration": {
            "fi": "730 päivää",
            "sv": "730 dagar",
            "en": "730 days"
          }
        },
        {
          "name": "SAPISID",
          "host": "youtube.com, google.com",
          "storageType": 1,
          "description": {
            "fi": "Googlen eväste, jota hyödynnetään personoidun sisällön näyttämiseen Googlen palveluissa.",
            "sv": "Googles cookie som tillhandahåller visning av personligt innehåll på Googles tjänster.",
            "en": "Google's cookie that provides displaying personalized content on Google services."
          },
          "expiration": {
            "fi": "730 päivää",
            "sv": "730 dagar",
            "en": "730 days"
          }
        },
        {
          "name": "SSID",
          "host": "youtube.com, google.com",
          "storageType": 1,
          "description": {
            "fi": "Googlen eväste, jota hyödynnetään personoidun sisällön näyttämiseen Googlen palveluissa.",
            "sv": "Googles cookie som tillhandahåller visning av personligt innehåll på Googles tjänster.",
            "en": "Google's cookie that provides displaying personalized content on Google services."
          },
          "expiration": {
            "fi": "730 päivää",
            "sv": "730 dagar",
            "en": "730 days"
          }
        },
        {
          "name": "SIDCC",
          "host": "youtube.com, google.com",
          "storageType": 1,
          "description": {
            "fi": "Googlen eväste, jota hyödynnetään personoidun sisällön näyttämiseen Googlen palveluissa sekä mainonnan käytön seuraamiseen.",
            "sv": "Googles cookie som tillhandahåller visning av personligt innehåll på Googles tjänster och tillåter spårning av hur användaren interagerar med den visade annonsen.",
            "en": "Google's cookie that provides displaying personalized content on Google services and allows tracking how the user interacts with the displayed advertisement."
          },
          "expiration": {
            "fi": "730 päivää",
            "sv": "730 dagar",
            "en": "730 days"
          }
        },
      ]
    }
  ],
  "translations": {
    "bannerAriaLabel": {
      "fi": "Evästeasetukset",
      "sv": "Cookie -inställningar",
      "en": "Cookie settings"
    },
    "heading": {
      "fi": "Evästeet {{siteName}}-sivustolla",
      "sv": "Kakor på webbplatsen {{siteName}}",
      "en": "Cookies on {{siteName}}"
    },
    "description": {
      "fi": "Tämä sivusto käyttää välttämättömiä evästeitä sivun perustoimintojen ja suorituskyvyn varmistamiseksi. Lisäksi käytämme kohdennusevästeitä käyttäjäkokemuksen parantamiseksi, analytiikkaan ja yksilöidyn sisällön näyttämiseen.",
      "sv": "Denna webbplats använder obligatoriska kakor för att säkerställa de grundläggande funktionerna och prestandan. Dessutom använder vi inriktningskakor för bättre användarupplevelse, analytik och individualiserat innehåll.",
      "en": "This website uses required cookies to ensure the basic functionality and performance. In addition, we use targeting cookies to improve the user experience, perform analytics and display personalised content."
    },
    "showDetails": {
      "fi": "Näytä yksityiskohdat",
      "sv": "Visa detaljer",
      "en": "Show details"
    },
    "hideDetails": {
      "fi": "Piilota yksityiskohdat",
      "sv": "Stänga detaljer",
      "en": "Hide details"
    },
    "formHeading": {
      "fi": "Tietoa sivustolla käytetyistä evästeistä",
      "sv": "Information om kakor som används på webbplatsen",
      "en": "About the cookies used on the website"
    },
    "formText": {
      "fi": "Sivustolla käytetyt evästeet on luokiteltu käyttötarkoituksen mukaan. Alla voit lukea eri luokista ja sallia tai kieltää evästeiden käytön.",
      "sv": "Kakorna som används på webbplatsen har klassificerats enligt användningsändamål. Du kan läsa om de olika klasserna och acceptera eller förbjuda användningen av kakor.",
      "en": "The cookies used on the website have been classified according to their intended use. Below, you can read about the various categories and accept or reject the use of cookies."
    },
    "highlightedGroup": {
      "fi": "Sinun on hyväksyttävä tämä kategoria, jotta voit näyttää valitsemasi sisällön.",
      "sv": "Du måste acceptera den här kategorin för att visa innehållet du har valt.",
      "en": "You need to accept this category to display the content you have selected."
    },
    "highlightedGroupAria": {
      "fi": "Hyvä tietää kategorialle: {{title}}",
      "sv": "Bra att veta för kategorin: {{title}}",
      "en": "Good to know for category: {{title}}"
    },
    "showCookieSettings": {
      "fi": "Näytä evästeasetukset",
      "sv": "Visa kakinställningarna",
      "en": "Show cookie settings"
    },
    "hideCookieSettings": {
      "fi": "Piilota evästeasetukset",
      "sv": "Stänga kakinställningarna",
      "en": "Hide cookie settings"
    },
    "acceptedAt": {
      "fi": "Olet hyväksynyt tämän kategorian: {{date}} klo {{time}}.",
      "sv": "Du har accepterat denna kategori: {{date}} kl. {{time}}.",
      "en": "You have accepted this category: {{date}} at {{time}}."
    },
    "tableHeadingsName": {
      "fi": "Nimi",
      "sv": "Namn",
      "en": "Name"
    },
    "tableHeadingsHostName": {
      "fi": "Evästeen asettaja",
      "sv": "Den som lagrat kakan",
      "en": "Cookie set by"
    },
    "tableHeadingsDescription": {
      "fi": "Käyttötarkoitus",
      "sv": "Användning",
      "en": "Purpose of use"
    },
    "tableHeadingsExpiration": {
      "fi": "Voimassaoloaika",
      "sv": "Giltighetstid",
      "en": "Period of validity"
    },
    "tableHeadingsType": {
      "fi": "Tyyppi",
      "sv": "Typ",
      "en": "Type"
    },
    "approveAllConsents": {
      "fi": "Hyväksy kaikki evästeet",
      "sv": "Acceptera alla kakor",
      "en": "Accept all cookies"
    },
    "approveRequiredAndSelectedConsents": {
      "fi": "Hyväksy valitut evästeet",
      "sv": "Acceptera valda kakor",
      "en": "Accept selected cookies"
    },
    "approveOnlyRequiredConsents": {
      "fi": "Hyväksy vain välttämättömät evästeet",
      "sv": "Acceptera endast nödvändiga",
      "en": "Accept required cookies only"
    },
    "settingsSaved": {
      "fi": "Asetukset tallennettu!",
      "sv": "Inställningar sparade!",
      "en": "Settings saved!"
    },
    "notificationAriaLabel": {
      "fi": "Ilmoitus",
      "sv": "Meddelande",
      "en": "Annoucement"
    },
    "storageType1": {
      "fi": "Eväste",
      "sv": "Kakan",
      "en": "Cookie"
    },
    "storageType2": "localStorage",
    "storageType3": "sessionStorage",
    "storageType4": "IndexedDB",
    "storageType5": "Cache Storage"
  }
};
