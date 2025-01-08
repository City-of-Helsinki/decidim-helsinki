// ! ! ! NOT PRODUCTION READY ! ! !
//
// This is currently only an example settings implementation copied from the
// default example at the site settings editor.
//
// In order to implement these settings, you can modify the settings by hand or
// generate the JSON at:
// https://hds.hel.fi/storybook/react/static-cookie-consent-editor/siteSettingsEditor.html
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
  "siteName": "Hel.fi",
  "cookieName": "helfi-cookie-consents",
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
          "name": "helfi-cookie-consents",
          "host": "www.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Sivusto käyttää tätä evästettä tietojen tallentamiseen siitä, ovatko kävijät antaneet hyväksyntänsä tai kieltäytyneet evästeiden käytöstä.",
            "sv": "Cookie möjliggör hantering av cookies på webbplatsen.",
            "en": "Used by www.hel.fi Drupal to store information about whether visitors have given or declined the use of cookie categories used on the www.hel.fi site."
          },
          "expiration": {
            "fi": "100 päivää",
            "sv": "100 dagar",
            "en": "100 days"
          }
        },
        {
          "name": "SSESS*",
          "host": "www.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Sisällönhallintajärjestelmän toimintaan liittyvä eväste.",
            "sv": "En cookie relaterad till driften av innehållshanteringssystemet.",
            "en": "A cookie related to the operation of the content management system."
          },
          "expiration": {
            "fi": "23 päivää",
            "sv": "23 dagar",
            "en": "23 days"
          }
        },
        {
          "name": "AWSELBCORS",
          "host": "siteimproveanalytics.io",
          "storageType": 1,
          "description": {
            "fi": "Eväste liittyy palvelinten kuormanjakotoiminnallisuuteen, jolla ohjataan pyynnöt vähimmällä käytöllä olevalle palvelimille.",
            "sv": "Cookie är kopplad till funktionen för lastfördelning som styr begäran till en server med mindre belastning.",
            "en": "The cookie is related to a load distribution function used to direct requests to servers with the least traffic."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "mtm_cookie_consent",
          "host": "kartta.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Tekninen eväste johon talletetaan tieto valinnastasi evästeiden käytöstä kertovan bannerin kohdalla",
            "sv": "A technical cookie that stores information about how you responded to the notice in the cookie banner about the use of cookies.",
            "en": "A technical cookie that stores information about how you responded to the notice in the cookie banner about the use of cookies."
          },
          "expiration": {
            "fi": "10950 päivää",
            "sv": "10950 dagar",
            "en": "10950 days"
          }
        },
        {
          "name": "JSESSIONID",
          "host": "helsinkikanava.fi, coh-chat-app-prod.eu-de.mybluemix.net",
          "storageType": 1,
          "description": {
            "fi": "Sivuston pakollinen eväste mahdollistaa kävijän vierailun sivustolla.",
            "sv": "Kakan är en obligatorisk kaka som gör det möjligt för besökaren att besöka webbplatsen.",
            "en": "The cookie is an obligatory cookie that facilitates visiting the website."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "JSESSIONID",
          "host": "coh-chat-app-prod.ow6i4n9pdzm.eu-de.codeengine.appdomain.cloud",
          "storageType": 1,
          "description": {
            "fi": "Käytetään chat-sovellustoiminnallisuutta varten. Evästettä käytetään sovelluksen palvelimella olevan istuntotiedon hakemiseen.",
            "sv": "Används för chattapplikationens funktionalitet. Dess värde används för att få tillgång till sessiondata på applikationens server.",
            "en": "Used for chat app functionality. Its value is used to access session data on server of the application."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "COOKIE_SUPPORT",
          "host": "helsinkikanava.fi",
          "storageType": 1,
          "description": {
            "fi": "Mahdollistaa evästeiden hallinnan sivustolla.",
            "sv": "Kakan möjliggör hanteringen av kakor på webbplatsen.",
            "en": "The cookie facilitates managing cookies on the website."
          },
          "expiration": {
            "fi": "365 päivää",
            "sv": "365 dagar",
            "en": "365 days"
          }
        },
        {
          "name": "GUEST_LANGUAGE_ID",
          "host": "helsinkikanava.fi",
          "storageType": 1,
          "description": {
            "fi": "Tämän evästeen on luonut Liferay, se tallentaa kieliasetukset.",
            "sv": "Denna cookie genereras av Liferay, dess funktion är att lagra språkinställningarna.",
            "en": "This cookie is generated by the Liferay, its function is to store the language preferences."
          },
          "expiration": {
            "fi": "365 päivää",
            "sv": "365 dagar",
            "en": "365 days"
          }
        },
        {
          "name": "helfi-settings",
          "host": "www.hel.fi",
          "storageType": 2,
          "description": {
            "fi": "Sivusto käyttää tätä tietuetta tietojen tallentamiseen siitä, mitä poikkeusilmoituksia on suljettu ja mikä on avattavien sisältöalueiden tila.",
            "sv": "Används av hel.fi Drupal för att lagra information om stängda meddelanden och accordions' tillstånd.",
            "en": "Used by hel.fi Drupal to store information about closed announcements and accordions' state."
          },
          "expiration": "-"
        }
      ]
    },
    {
      "groupId": "admin",
      "title": {
        "fi": "Sisällöntuottajien toiminnalliset evästeet",
        "sv": "Redaktörernas funktionella cookies",
        "en": "Editors' functional cookies"
      },
      "description": {
        "fi": "Sisäänkirjautuneiden sisällöntuottajien välttämättömät toiminnalliset evästeet mahdollistavat editointityökalujen käytön niitä käyttäville. Näitä evästeitä ei aseteta kirjautumattomille käyttäjille.",
        "sv": "Nödvändiga funktionella cookies för inloggade redaktörer möjliggör användning av redigeringsverktyg för dem som använder dem. Dessa cookies är inte inställda för icke-inloggade användare.",
        "en": "Necessary functional cookies for logged-in editors enable the use of editing tools for those who use them. These cookies are not set for non-logged in users."
      },
      "cookies": [
        {
          "name": "editoria11yResultCount",
          "host": "www.hel.fi",
          "storageType": 2,
          "description": {
            "fi": "Tallentaa sisällöntuottajan näkemien saavutettavuusongelmien lukumäärän nykyisellä sivulla.",
            "sv": "Spårar tillgänglighetsproblem för den aktuella sidan när du är inloggad som redaktör på hel.fi.",
            "en": "Tracks accessibility issues for the current page when logged in as an editor on hel.fi."
          },
          "expiration": "-"
        },
        {
          "name": "Drupal.gin.sidebarExpanded.desktop",
          "host": "www.hel.fi",
          "storageType": 2,
          "description": {
            "fi": "Tallentaa tiedon sisällöntuottajan käyttöliittymän sivupalkin näkyvyydestä työpöytänäkymässä.",
            "sv": "Lagrar om admin-sidopanelen är expanderad eller kollapsad på skrivbordet när du är inloggad som redaktör på hel.fi.",
            "en": "Stores whether the admin sidebar is expanded or collapsed on desktop when logged in as an editor on hel.fi."
          },
          "expiration": "-"
        },
        {
          "name": "Drupal.gin.sidebarExpanded.mobile",
          "host": "www.hel.fi",
          "storageType": 2,
          "description": {
            "fi": "Tallentaa tiedon sisällöntuottajan käyttöliittymän sivupalkin näkyvyydestä mobiilinäkymässä.",
            "sv": "Lagrar om admin-sidopanelen är expanderad eller kollapsad på mobil när du är inloggad som redaktör på hel.fi.",
            "en": "Stores whether the admin sidebar is expanded or collapsed on mobile when logged in as an editor on hel.fi."
          },
          "expiration": "-"
        },
        {
          "name": "Drupal.gin.darkmode",
          "host": "www.hel.fi",
          "storageType": 2,
          "description": {
            "fi": "Tallentaa tiedon sisällöntuottajan valitsemasta \"tumma tila\"-asetuksesta.",
            "sv": "Lagrar användarens mörkt läge-inställning i admin-temat när du är inloggad som redaktör på hel.fi.",
            "en": "Stores the user's dark mode preference in the admin theme when logged in as an editor on hel.fi."
          },
          "expiration": "-"
        },
        {
          "name": "Drupal.toolbar.subtrees.*",
          "host": "www.hel.fi",
          "storageType": 2,
          "description": {
            "fi": "Tallentaa sisällöntuottajan näkymissä alivalikoiden tilan (laajennettu tai kutistettu), jotta se säilyy yhdenmukaisena sivulatausten välillä.",
            "sv": "Lagrar tillståndet för expanderade eller kollapsade undermenyer i Drupals admin-verktygsfält för en inloggad redaktör, vilket säkerställer konsekvens mellan sidladdningar.",
            "en": "Stores the expanded or collapsed state of submenus in the Drupal admin toolbar for a logged-in editor, ensuring consistency across page loads."
          },
          "expiration": "-"
        },
        {
          "name": "Drupal.off-canvas.css.*",
          "host": "www.hel.fi",
          "storageType": 2,
          "description": {
            "fi": "Tallentaa sisällöntuottajan käyttämän wysiwyg-editorin tyylit välimuistiin varmistaakseen viimeisimpien CSS-tyylien latauksen.",
            "sv": "Lagrar cachelagrad CKEditor CSS i localStorage för en inloggad redaktör, med en nyckel som använder en cache-brytande fråga för att säkerställa att den senaste CSS-filen laddas.",
            "en": "Stores cached CKEditor CSS in localStorage for a logged-in editor, using a key with a cache-busting query to ensure the latest CSS is loaded."
          },
          "expiration": "-"
        },
        {
          "name": "ed11ySeen",
          "host": "www.hel.fi",
          "storageType": 2,
          "description": {
            "fi": "Tallentaa sisällöntuottajan näkemät saavutettavuusongelmat, jotta vältetään ongelmien kaksoisilmoitukset.",
            "sv": "Spårar vilka tillgänglighetsproblem en inloggad redaktör redan har sett för att undvika dubbla aviseringar.",
            "en": "Tracks which accessibility issues a logged-in editor has already seen to avoid duplicate notifications."
          },
          "expiration": "-"
        },
        {
          "name": "Drupal.toolbar.toolbarState",
          "host": "www.hel.fi",
          "storageType": 3,
          "description": {
            "fi": "Tallentaa sisällöntuottajan hallintatyökalupalkin orientaation, aktiivisen välilehden ja laajennustilan.",
            "sv": "Lagrar tillståndet för admin-verktygsfältet för en inloggad redaktör, inklusive dess orientering, aktiva flik och expanderade tillstånd.",
            "en": "Stores the state of the admin toolbar for a logged-in editor, including its orientation, active tab and state of expansion."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "escapeAdminPath",
          "host": "www.hel.fi",
          "storageType": 3,
          "description": {
            "fi": "Tallentaa URL-osoitteen, jota käytetään ohjaamaan kirjautunut sisällöntuottaja hallintaliittymästä takaisin pääsivustolle.",
            "sv": "Lagrar URL för att omdirigera en inloggad redaktör från admin-gränssnittet tillbaka till huvudsidan.",
            "en": "Stores the URL to redirect a logged-in editor from the admin interface back to the main site."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
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
          "name": "httpskartta.hel.fi.SWCulture",
          "host": "kartta.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Kaupungin karttapalvelun evästeeseen tallennetaan kieli, jolla palvelua käytetään.",
            "sv": "I kakan på stadens kaktjänst sparas det språk som användaren använder i tjänsten.",
            "en": "The City's map service cookie saves the language in which the service is used."
          },
          "expiration": {
            "fi": "1826 päivää",
            "sv": "1826 dagar",
            "en": "1826 days"
          }
        },
        {
          "name": "icareus-device",
          "host": "helsinkikanava.fi",
          "storageType": 1,
          "description": {
            "fi": "Helsinki-kanavan videopalvelimen eväste.",
            "sv": "Helsinki-kanavas kaka gör det möjligt att göra videor till en del av innehållet på webbplatsen.",
            "en": "The Helsinki Channel video server cookie facilitates including videos as part of the website's content."
          },
          "expiration": {
            "fi": "365 päivää",
            "sv": "365 dagar",
            "en": "365 days"
          }
        },
        {
          "name": "VISITOR_INFO1_LIVE",
          "host": "youtube.com",
          "storageType": 1,
          "description": {
            "fi": "YouTuben eväste valitsee yhteyden nopeuden mukaan, joko vanhan tai uuden videosoittimen.",
            "sv": "YouTubes kaka väljer antingen den nya eller gamla videospelaren enligt förbindelsens hastighet.",
            "en": "The YouTube cookie selects the old or new video player depending on the connection speed."
          },
          "expiration": {
            "fi": "180 päivää",
            "sv": "180 dagar",
            "en": "180 days"
          }
        },
        {
          "name": "CONSENT",
          "host": "youtube.com",
          "storageType": 1,
          "description": {
            "fi": "Googlen eväste tallentaa kävijän evästehyväskynnän.",
            "sv": "Används av Google för att lagra inställningar för användarens samtycke",
            "en": "Used by Google to store user consent preferences"
          },
          "expiration": {
            "fi": "5947 päivää, 15 tuntia",
            "sv": "5947 dagar, 15 timmar",
            "en": "5947 days, 15 hours"
          }
        },
        {
          "name": "activeTab",
          "host": "www.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Käytetään aktiivisten välilehtien tietojen tallentamiseen, kun käyttäjä käyttää lukioiden suodatushakua.",
            "sv": "Används för att lagra aktiv flikdata när användaren använder gymnasiesökning.",
            "en": "Used for storing active tab data when user is using high school search."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "activeContent",
          "host": "www.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Käytetään aktiivisen sisältötietojen tallentamiseen, kun käyttäjä käyttää lukioiden hakua.",
            "sv": "Används för att lagra aktivt innehållsdata när användaren använder gymnasiesökning.",
            "en": "Used for storing active content data when user is using high school search."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        }
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
        "sv": "De uppgifter statistikkakorna samlar in används för att utveckla webbplatsen.",
        "en": "The information collected by statistics cookies is used for developing the website."
      },
      "cookies": [
        {
          "name": "nmstat",
          "host": "www.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Siteimproven tilastointieväste kerää tietoa kävijän sivujen käytöstä.",
            "sv": "Siteimproves kaka samlar information om hur webbplatsen används.",
            "en": "The Siteimprove statistics cookie collects information about the use of the website."
          },
          "expiration": {
            "fi": "1000 päivää",
            "sv": "1000 dagar",
            "en": "1000 days"
          }
        },
        {
          "name": "_pk_id.*",
          "host": "www.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Matomo-tilastointijärjestelmän eväste.",
            "sv": "Matomo-statistiksystemets kaka samlar information om hur webbplatsen används.",
            "en": "Matomo Analytics - used to store a few details about the user such as the unique visitor ID"
          },
          "expiration": {
            "fi": "393 päivää",
            "sv": "393 dagar",
            "en": "393 days"
          }
        },
        {
          "name": "_pk_ses.141.89f6",
          "host": "www.hel.fi",
          "storageType": 1,
          "description": "-",
          "expiration": {
            "fi": "1 tunti",
            "sv": "1 timme",
            "en": "1 hour"
          }
        },
        {
          "name": "_pk_id.*",
          "host": "kartta.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Matomo-tilastointijärjestelmän eväste.",
            "sv": "Matomo-statistiksystemets kaka samlar information om hur webbplatsen används.",
            "en": "Matomo Analytics - used to store a few details about the user such as the unique visitor ID"
          },
          "expiration": {
            "fi": "393 päivää",
            "sv": "393 dagar",
            "en": "393 days"
          }
        },
        {
          "name": "_pk_ses.*",
          "host": "kartta.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Matomo-tilastointijärjestelmän eväste.",
            "sv": "Matomo-statistiksystemets kaka samlar information om hur webbplatsen används.",
            "en": "Matomo Analytics - used to store a few details about the user such as the unique visitor ID"
          },
          "expiration": {
            "fi": "1 tunti",
            "sv": "1 timme",
            "en": "1 hour"
          }
        },
        {
          "name": "_pk_id.*",
          "host": "palvelukartta.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Matomo-tilastointijärjestelmän eväste.",
            "sv": "Matomo-statistiksystemets kaka samlar information om hur webbplatsen används.",
            "en": "Matomo Analytics - used to store a few details about the user such as the unique visitor ID"
          },
          "expiration": {
            "fi": "393 päivää",
            "sv": "393 dagar",
            "en": "393 days"
          }
        },
        {
          "name": "_pk_ses.*",
          "host": "palvelukartta.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Matomo-tilastointijärjestelmän eväste.",
            "sv": "Matomo-statistiksystemets kaka samlar information om hur webbplatsen används.",
            "en": "Matomo Analytics - used to store a few details about the user such as the unique visitor ID"
          },
          "expiration": {
            "fi": "1 tunti",
            "sv": "1 timme",
            "en": "1 hour"
          }
        },
        {
          "name": "rnsbid",
          "host": "reactandshare.com",
          "storageType": 2,
          "description": {
            "fi": "Askem-reaktionappien toimintaan liittyvä tietue.",
            "sv": "En post relaterad till driften av reaktionsknappen Askem",
            "en": "A record related to the operation of the Askem react buttons."
          },
          "expiration": "-"
        },
        {
          "name": "rnsbid_ts",
          "host": "reactandshare.com",
          "storageType": 2,
          "description": {
            "fi": "Askem-reaktionappien toimintaan liittyvä tietue.",
            "sv": "En post relaterad till driften av reaktionsknappen Askem",
            "en": "A record related to the operation of the Askem react buttons."
          },
          "expiration": "-"
        },
        {
          "name": "rns_reaction_*",
          "host": "reactandshare.com",
          "storageType": 2,
          "description": {
            "fi": "Askem-reaktionappien toimintaan liittyvä tietue.",
            "sv": "En post relaterad till driften av reaktionsknappen Askem",
            "en": "A record related to the operation of the Askem react buttons."
          },
          "expiration": "-"
        },
        {
          "name": "YSC",
          "host": "youtube.com",
          "storageType": 1,
          "description": {
            "fi": "YouTuben eväste mahdollistaa videoiden upottamisen sivustolle.",
            "sv": "YouTubes kaka gör det möjligt att göra videor till en del av innehållet på webbplatsen.",
            "en": "The YouTube cookie facilitates including videos as part of the website's content."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        }
      ]
    },
    {
      "groupId": "chat",
      "title": {
        "fi": "Toiminnalliset chat-evästeet",
        "sv": "Funktionella chattkakor",
        "en": "Functional chat cookies"
      },
      "description": {
        "fi": "Toiminnallisten chat-evästeiden avulla mahdollistetaan helfi-sivujen chattien toiminta. Jos aloitat chatin, hyväksyt sen käyttöön liittyvät toiminnalliset evästeet automaattisesti.  Evästeiden hyväksymiseen ei tällöin tarvita erillistä suostumusta. Toiminnallisia chat-evästeitä ladataan laitteellesi vain, jos käynnistät chatin.",
        "sv": "Chattarna på webbplatsen hel.fi  fungerar med hjälp av funktionella chattkakor. Om du inleder en chatt godkänner du automatiskt de nödvändiga funktionella kakorna.  Då behövs inget separat samtycke till kakor. Funktionella chattkakor laddas endast ner på din enhet om du inleder en chatt.",
        "en": "The chats on the hel.fi  website require functional chat cookies to function. By using a chat, you automatically accept the functional cookies it requires.  No separate cookie consent is needed. Functional chat cookies are only downloaded to your device if you start a chat."
      },
      "cookies": [
        {
          "name": "_genesys.widgets.*",
          "host": "www.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Käytetään chatin tarvitseman datan tallentamiseen.",
            "sv": "Käytetään chatin tarvitseman datan tallentamiseen.",
            "en": "Used for storing data required by the chat functionality."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "leijuke.*",
          "host": "www.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Käytetään chatin tarvitseman datan tallentamiseen.",
            "sv": "Käytetään chatin tarvitseman datan tallentamiseen.",
            "en": "Used for storing data required by the chat functionality."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "aiap-wbc-chat-app-button-state",
          "host": "www.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Käytetään chat-sovellustoiminnallisuutta varten. Säilyttää chat-sovelluksen painikkeen asetukset ja kokoonpanotiedot.",
            "sv": "Används för chattapplikationens funktionalitet. Lagrar inställningar och konfigurationsdata för chattapplikationens knapp.",
            "en": "Used for chat app functionality. Stores chat app button settings and configuration data."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "aiap-chat-app-v1-state",
          "host": "www.hel.fi",
          "storageType": 1,
          "description": {
            "fi": "Käytetään chat-sovellustoiminnallisuutta varten. Säilyttää chat-sovelluksen asetukset ja kokoonpanotiedot.",
            "sv": "Används för chattapplikationens funktionalitet. Lagrar inställningar och konfigurationsdata för chattapplikationen.",
            "en": "Used for chat app functionality. Stores chat app settings and configuration data."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "conversationToken",
          "host": "https://coh-chat-app-prod.ow6i4n9pdzm.eu-de.codeengine.appdomain.cloud",
          "storageType": 1,
          "description": {
            "fi": "Käytetään chat-sovellustoiminnallisuutta varten. Säilyttää chat-sovelluksen keskustelutunnisteen istunnnon tunnistamista ja tietojen hakemista varten.",
            "sv": "Används för chattapplikationens funktionalitet. Lagrar konversationstoken för autentisering och åtkomst till dataändamål.",
            "en": "Used for chat app functionality. Stores chat app conversation token for authentication and data access purposes."
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "CallGuide.language",
          "host": "www.hel.fi",
          "storageType": 2,
          "description": {
            "fi": "ACE Chat: ACE Web SDK:ssa käytettävä kieli, joka on johdettu selainten ensisijaisesta kieliasetuksesta ja ACE Web SDK - asetuksista.",
            "sv": "ACE Chat: Språket som används i ACE Web SDK härleds från webbläsarnas föredragna språkinställning och ACE Web SDK-inställningar.",
            "en": "ACE Chat: The language used in the ACE Web SDK is derived from the browsers' preferred language setting and ACE Web SDK settings."
          },
          "expiration": "-"
        },
        {
          "name": "CallGuide.config_services_*",
          "host": "www.hel.fi",
          "storageType": 2,
          "description": {
            "fi": "ACE Chat: Asiakaspalveluintegraatioiden määritys verkkosivulla. Vähentää verkkoliikennettä sivun lataamisen ja navigoinnin yhteydessä.",
            "sv": "ACE Chatt: Konfigurera kundtjänstintegrationer på en webbsida. Minskar webbtrafiken när du läser in och navigerar på en sida.",
            "en": "ACE Chat: The unique identity of this browser window. Is used if the browser has more than one open window for a website"
          },
          "expiration": "-"
        },
        {
          "name": "*_CGWebSDK_windowGUID",
          "host": "wds.ace.teliacompany.com",
          "storageType": 1,
          "description": {
            "fi": "ACE Chat: Tämän selainikkunan yksilöllinen identiteetti. Käytetään, jos selaimessa on useampi kuin yksi avoin ikkuna verkkosivustolle.",
            "sv": "ACE Chatt: Den unika identiteten för det här webbläsarfönstret. Används om webbläsaren har mer än ett öppet fönster för en webbplats.",
            "en": "ACE Chat: The unique identity of this browser window. Is used if the browser has more than one open window for a website"
          },
          "expiration": "-"
        },
        {
          "name": "*_CGWebSDK_videoShower",
          "host": "wds.ace.teliacompany.com",
          "storageType": 2,
          "description": {
            "fi": "ACE Chat: Vain yksi ikkuna kerrallaan voi näyttää videota. Nämä tiedot seuraavat, mikä niistä (jos sellainen on).",
            "sv": "ACE Chatt: Endast ett fönster i taget kan visa video. Den här informationen spårar vilka av dem (om några).",
            "en": "ACE Chat: Only one window at a time can display video. This information tracks which of them (if any).\t-"
          },
          "expiration": "-"
        },
        {
          "name": "*_CGWebSDK_videoClients",
          "host": "wds.ace.teliacompany.com",
          "storageType": 2,
          "description": {
            "fi": "ACE Chat: Luettelo kaikista ikkunoista, jotka ovat todennäköisiä videon näyttämiseen.",
            "sv": "ACE Chatt: En lista över alla fönster som sannolikt kommer att visa videon.",
            "en": "ACE Chat: A list of all windows that are likely to display the video"
          },
          "expiration": "-"
        },
        {
          "name": "*_ACEChatState_ActiveClient",
          "host": "wds.ace.teliacompany.com",
          "storageType": 2,
          "description": {
            "fi": "ACE Chat: Verkkosivustolla voi olla useampi kuin yksi chat-asiakasohjelma. Tämä kohde seuraa, mihin asiakkaaseen nykyinen chat kuuluu.",
            "sv": "ACE Chatt: En webbplats kan ha mer än en chattklient. Det här objektet spårar vilken kund den aktuella chatten tillhör.",
            "en": "ACE Chat: A website can have more than one chat client. This item tracks which customer the current chat belongs to."
          },
          "expiration": "-"
        },
        {
          "name": "*_chatEntrance",
          "host": "wds.ace.teliacompany.com",
          "storageType": 1,
          "description": {
            "fi": "ACE Chat: Järjestelmän chat-sisäänkäynnin nimi",
            "sv": "ACE Chatt: Namnet på chattingången till systemet",
            "en": "ACE Chat: Name of the chat entrance to the system"
          },
          "expiration": "-"
        },
        {
          "name": "*_chatUID",
          "host": "wds.ace.teliacompany.com",
          "storageType": 1,
          "description": {
            "fi": "ACE Chat: Keskustelun istuntotunnus kommunikoitaessa ACE:n kanssa",
            "sv": "ACE Chatt: Chattsessions-ID vid kommunikation med ACE",
            "en": "ACE Chat: Chat session ID when communicating with ACE"
          },
          "expiration": "-"
        },
        {
          "name": "humany-*",
          "host": "www.hel.fi",
          "storageType": 2,
          "description": {
            "fi": "ACE Chat: Säilyttää widgetin tilan, kun sivu ladataan uudelleen",
            "sv": "ACE Chatt: Bevarar widgetstatus när sidan laddas om",
            "en": "ACE Chat: Preserves widget status when page reloads"
          },
          "expiration": "-"
        },
        {
          "name": "ARRAffinity",
          "host": ".hel.humany.net",
          "storageType": 1,
          "description": {
            "fi": "ACE Chat: Kuormituksen tasaus taustajärjestelmässä",
            "sv": "ACE Chatt: Lastbalansering i backend-systemet",
            "en": "ACE Chat: Load balancing in the backend system"
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        },
        {
          "name": "ARRAffinitySameSite",
          "host": ".hel.humany.net",
          "storageType": 1,
          "description": {
            "fi": "ACE Chat: Kuormituksen tasaus taustajärjestelmässä",
            "sv": "ACE Chatt: Lastbalansering i backend-systemet",
            "en": "ACE Chat: Load balancing in the backend system"
          },
          "expiration": {
            "fi": "Istunto",
            "sv": "Session",
            "en": "Session"
          }
        }
      ]
    }
  ],
  "robotCookies": [
    {
      "name": "helfi_accordions_open",
      "storageType": 1
    }
  ],
  "groupsWhitelistedForApi": [
    "chat"
  ],
  "translations": {
    "bannerAriaLabel": {
      "fi": "Evästeasetukset",
      "sv": "Inställningar för kakor",
      "en": "Cookie settings"
    },
    "heading": {
      "fi": "{{siteName}} käyttää evästeitä",
      "sv": "{{siteName}} använder kakor",
      "en": "{{siteName}} uses cookies"
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
