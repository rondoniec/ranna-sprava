const ISSUES = [
  {
    number: 57,
    title: "Poslanec s 45-tisíc eurami v garáži. Ferenčák tvrdí, že šlo o pôžičku.",
    date: "2026-03-26",
    dateLabel: "Štvrtok, 26. marca",
    preview: "Na sociálnych sieťach koluje video, kde poslanec Ferenčák odovzdáva 45 000 eur v hotovosti. Slovensko zdvojnásobilo cenu nafty pre cudzincov — Brusel pohrozil konaním. EP schválil dohodu Turnberry s USA. Dnes večer Slovensko hrá o MS 2026 s Kosovom.",
    tags: ["slovensko", "politika", "koalicia"],
  },
  {
    number: 56,
    title: "Slovensko žaluje Úniu. Fico napadol zákaz ruského plynu na Súdnom dvore EÚ.",
    date: "2026-03-25",
    dateLabel: "Streda, 25. marca",
    preview: "Fico podal žalobu na EÚ Court pre zákaz ruského plynu — tvrdí, že Brusel obišiel jednomyseľnosť. Slovenská inflácia mierne klesla na 3,7 %. EP hlasuje o obchodnej dohode s USA.",
    tags: ["slovensko", "energia", "eu"],
  },
  {
    number: 55,
    title: "SaS podala trestné oznámenie na Fica pre vlastizradu. A Pellegrini sám žiadal Kremlin o pomoc pred voľbami.",
    date: "2026-03-24",
    dateLabel: "Utorok, 24. marca",
    preview: "Bratislavská prokuratúra preberá prípad velezrady premiéra Fica. Pellegrini sám žiadal Orbána o pomoc od Kremľa — je dnes prezidentom. Slovensko žiada inšpekciu ropovodu Džba.",
    tags: ["slovensko", "politika", "svet"],
  },
  {
    number: 54,
    title: "Jansša nedokázal vyhrať. Golob nedokázal presvedčiť. Slovinsko sa prebudilo do nerozhodna.",
    date: "2026-03-23",
    dateLabel: "Pondelok, 23. marca",
    preview: "Slovinské voľby skončili najtesnejším výsledkom za desaťročia — Golob a Jansša sú od seba vzdialení menej ako tri percentá. Ak Jansša zostaví vládu, Orbán má nového spojenca. Fico medzitým pohrozil vetom 90 miliárd pre Ukrajinu. Česko ponúka Slovensku nový ropovod. A Kuba ostala bez svetla — po tretíkrát tento mesiac.",
    tags: ["svet", "politika"],
  },
  {
    number: 53,
    title: "Hormuz musí byť otvorený do 48 hodín. Inak Trump zasiahne elektrárne.",
    date: "2026-03-22",
    dateLabel: "Nedeľa, 22. marca",
    preview: "Dvadsaťtretí deň vojny USA a Izraela s Iránom. Trump dal Teheránu 48 hodín na otvorenie Hormuzského prielivu — inak zasiahne iránske elektrárne. Brent na 112 dolároch. V Prahe 250 000 demonštrantov hovorí: nechceme sa stať Slovenskom.",
    tags: ["svet", "energia"],
  },
  {
    number: 52,
    title: "Orbán vyhral summit. Únia odišla domov s prázdnymi rukami.",
    date: "2026-03-21",
    dateLabel: "Sobota, 21. marca",
    preview: "Dvojdňový summit EÚ skončil bez dohody o úvere 90 miliárd eur pre Ukrajinu. Záverečné závery podpísalo 25 z 27 štátov — Maďarsko a Slovensko nie. Orbán odchádzal v dobrej nálade.",
tags: ["eu", "diplomacia"],
  },
  {
    number: 51,
    title: "Prídely nafty od dnes. Slovensko zaviedlo núdzový režim na čerpačkách.",
    date: "2026-03-20",
    dateLabel: "Piatok, 20. marca",
preview: "Od dnešného rána platia na slovenských čerpacích staniciach opatrenia, aké sme tu ešte nemali — prídely nafty, zákaz exportu a vyššie ceny pre cudzincov. Ropovod Družba zostáva prázdny. Je prvý deň jari.",
    tags: ["slovensko", "energia"],
  },
    {
    number: 50,
    title: "Orbán prišiel do Bruselu. A priniesol si „nie\".",
    date: "2026-03-17",
    dateLabel: "Streda, 18. marca",
    preview: "Dnes v Bruseli zasadá summit lídrov EÚ — a ešte pred prvým kávou je jasné, že to nebude nudné. Maďarský premiér Viktor Orbán prišiel s jasnou správou: kým Kyjev neobnoví toky ruskej ropy cez ropovod Družba, Maďarsko nezruší veto na pôžičku 90 miliárd eur pre Ukrajinu.",
    tags: ["slovensko", "energia"],
  },
  {
    number: 492,
    title: "Praha ide na miesto činu. Bratislava čaká, čo nájdu.",
    date: "2026-03-17",
    dateLabel: "Utorok, 17. marca",
    preview: "Česko ponúklo viesť európsku inšpekčnú misiu priamo na poškodený ropovod Družba na Ukrajine — Slovensko bez ruskej ropy už takmer 50 dní. Doma Danko po sneme znovu kritizuje Fica, ale vládu nepovalí. A ropa Brent prekonala 100 dolárov.",
    tags: ["slovensko", "energia"],
  },
  {
    number: 49,
    title: "Spojenci povedali nie. A Trump im pohrozil zlou budúcnosťou.",
    date: "2026-03-17",
    dateLabel: "Utorok, 17. marca",
    preview: "Európa povedala Trumpovi nie — spojenci odmietli vyslať vojnové lode do Hormuzského prielivu a ceny ropy prekonali 100 dolárov. Doma Fico mení 20-ročný postoj a chce zo štátnych nemocníc akciové spoločnosti, lebo ich dlhy presiahli miliardu eur.",
    tags: ["slovensko", "biznis"]
  },
  {
    number: 48,
    title: "Slovensko ustúpilo. Alebo teda — skoro.",
    date: "2026-03-16",
    dateLabel: "Pondelok, 16. marca",
    preview: "Bratislava cez víkend pustila brzdu na sankciách EÚ, hoci chcela vyradiť Fridmana a Usmanova. Spor o ropovod Družba medzitým mení diplomaciu na servis potrubia. A Wizz Air dnes otvára nové linky z Bratislavy.",
    tags: ["slovensko", "eu"]
  },
  {
    number: 3,
    title: "Nový zákon o daniach, Tesla lacnie, Slovan v osemfinále",
    date: "2025-03-05",
    dateLabel: "Streda, 5. marca",
    preview: "Zmeny daní sa dotknú 85 000 živnostníkov. Tesla znížila ceny v EÚ o 8%. Slovan postúpil do osemfinále Európskej ligy.",
    tags: ["slovensko", "biznis", "tech", "sport"]
  },
  {
    number: 2,
    title: "Voľby sa blížia, AI Act finalizovaný, Tesla lacnie",
    date: "2025-03-04",
    dateLabel: "Utorok, 4. marca",
    preview: "Predvolebná kampaň naberá tempo. EÚ dokončila AI Act. Tesla znížila ceny v Európe.",
    tags: ["slovensko", "biznis", "tech"]
  },
  {
    number: 1,
    title: "Digitálna identita, inflácia padá, Resco získal 8M€",
    date: "2025-03-03",
    dateLabel: "Pondelok, 3. marca",
    preview: "Parlament schválil zákon o eID. Inflácia na najnižšej hodnote od 2021. Bratislavský startup Resco pokračuje v expanzii.",
    tags: ["slovensko", "biznis", "tech", "sport"]
  }
];
