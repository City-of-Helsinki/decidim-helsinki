# frozen_string_literal: true

module Helsinki
  # Metadata for the schools in Helsinki
  class SchoolMetadata
    # Types:
    # 11: elementary school (first level)
    # 12: elementary school, special schools (first level)
    # 15: high school (second level)
    # 19: elementary school + high school (first level + second level)
    # 21: vocational school (second level)
    # 22: vocational special school (second level)
    # 23: vocational special school (second level)
    #
    # See: http://www.tilastokeskus.fi/meta/luokitukset/oppilaittostyyp/001-1999/index.html
    #
    # Voting units (Ruuti budjetti):
    # 1: Herttoniemi
    # 2: Itäkeskus
    # 3: Kontula
    # 4: Vuosaari
    # 5: Ympäristötoiminta
    # 6: Eteläinen
    # 7: Haaga
    # 8: Kannelmäki
    # 9: Munkkiniemi
    # 10: Helsingfors svenska
    # 11: Pasila
    # 12: Malmi
    # 13: Maunula
    # 14: Koillinen
    # 15: Viikki
    #
    # NOTE:
    # This list only contains the Helsinki schools that take part in the voting.
    MAPPING = {
      # Test school code passed for the test authorizer by MPASSid
      # "00000" => { name: "Testikoulu", type: 11, postal_code: "00210", voting_unit: 6 },

      # Actual schools
      "00004" => { name: "Alppilan lukio", type: 15, postal_code: "00510", voting_unit: nil },
      "00026" => { name: "Brändö gymnasium", type: 15, postal_code: "00570", voting_unit: nil },
      "00081" => { name: "Helsingin luonnontiedelukio", type: 15, postal_code: "00610", voting_unit: nil },
      "00082" => { name: "Ressun lukio", type: 15, postal_code: "00270", voting_unit: nil },
      "00083" => { name: "Helsingin normaalilyseo", type: 19, postal_code: "00120", voting_unit: 6 },
      "00084" => { name: "Helsingin ranskalais-suomalainen koulu", type: 19, postal_code: "00350", voting_unit: 9 },
      "00085" => { name: "Helsingin saksalainen koulu", type: 19, postal_code: "00100", voting_unit: 6 },
      "00087" => { name: "Suomalais-venäläinen koulu", type: 19, postal_code: "00420", voting_unit: 8 },
      "00088" => { name: "Helsingin kuvataidelukio", type: 15, postal_code: "00500", voting_unit: nil },
      "00089" => { name: "Sibelius-lukio", type: 15, postal_code: "00170", voting_unit: nil },
      "00255" => { name: "Kallion lukio", type: 15, postal_code: "00530", voting_unit: nil },
      "00316" => { name: "Eiran aikuislukio", type: 15, postal_code: "00150", voting_unit: nil },
      "00394" => { name: "Englantilainen koulu", type: 19, postal_code: "00270", voting_unit: 7 },
      "00518" => { name: "Mäkelänrinteen lukio", type: 15, postal_code: "00550", voting_unit: nil },
      "00539" => { name: "Töölön yhteiskoulun aikuislukio", type: 15, postal_code: "00250", voting_unit: nil },
      "00551" => { name: "Helsingin aikuislukio", type: 15, postal_code: "00550", voting_unit: nil },
      "00561" => { name: "Gymnasiet Lärkan", type: 15, postal_code: "00320", voting_unit: nil },
      "00607" => { name: "Tölö gymnasium", type: 15, postal_code: "00260", voting_unit: nil },
      "00648" => { name: "Helsingin medialukio", type: 15, postal_code: "00730", voting_unit: nil },
      "00670" => { name: "Helsingin  kielilukio", type: 15, postal_code: "00900", voting_unit: nil },
      "00729" => { name: "Helsingin Rudolf Steiner -koulu", type: 19, postal_code: "00280", voting_unit: 9 },
      "00842" => { name: "HY Viikin normaalikoulu", type: 19, postal_code: "00790", voting_unit: 15 },
      "00845" => { name: "Etu-Töölön lukio", type: 15, postal_code: "00100", voting_unit: nil },
      "00915" => { name: "Vuosaaren lukio", type: 15, postal_code: "00980", voting_unit: nil },
      "01164" => { name: "H:gin Maalariammattikoulu", type: 21, postal_code: "00380", voting_unit: nil },
      "01294" => { name: "Suomen Diakoniaopisto", type: 21, postal_code: "00530", voting_unit: nil },
      "01428" => { name: "Jollas-opisto Oy", type: 21, postal_code: "00510", voting_unit: nil },
      "02558" => { name: "Suomen kansallisoopperan ja -baletin balettioppilaitos", type: 21, postal_code: "00530", voting_unit: nil },
      "03002" => { name: "Aleksis Kiven peruskoulu", type: 11, postal_code: "00510", voting_unit: 6 },
      "03004" => { name: "Haagan peruskoulu", type: 11, postal_code: "00320", voting_unit: 7 },
      "03005" => { name: "Hertsikan ala-aste", type: 11, postal_code: "00800", voting_unit: 1 },
      "03010" => { name: "Kaisaniemen ala-asteen koulu", type: 11, postal_code: "00100", voting_unit: 6 },
      "03011" => { name: "Kallion ala-asteen koulu", type: 11, postal_code: "00530", voting_unit: 6 },
      "03013" => { name: "Katajanokan ala-asteen koulu", type: 11, postal_code: "00160", voting_unit: 6 },
      "03014" => { name: "Konalan ala-asteen koulu", type: 11, postal_code: "08100", voting_unit: 7 },
      "03015" => { name: "Kontulan ala-asteen koulu", type: 11, postal_code: "00940", voting_unit: 3 },
      "03016" => { name: "Kulosaaren ala-asteen koulu", type: 11, postal_code: "00570", voting_unit: 1 },
      "03020" => { name: "Maunulan ala-asteen koulu", type: 11, postal_code: "00630", voting_unit: 13 },
      "03021" => { name: "Meilahden ala-asteen koulu", type: 11, postal_code: "00270", voting_unit: 9 },
      "03022" => { name: "Mellunmäen ala-asteen koulu", type: 11, postal_code: "00970", voting_unit: 3 },
      "03023" => { name: "Metsolan ala-asteen koulu", type: 11, postal_code: "00680", voting_unit: 13 },
      "03024" => { name: "Munkkiniemen ala-asteen koulu", type: 11, postal_code: "00330", voting_unit: 9 },
      "03025" => { name: "Munkkivuoren ala-asteen koulu", type: 11, postal_code: "00350", voting_unit: 9 },
      "03026" => { name: "Lauttasaaren ala-asteen koulu", type: 11, postal_code: "00200", voting_unit: 6 },
      "03030" => { name: "Oulunkylän ala-asteen koulu", type: 11, postal_code: "00640", voting_unit: 13 },
      "03032" => { name: "Pakilan ala-asteen koulu", type: 11, postal_code: "00660", voting_unit: 13 },
      "03033" => { name: "Pihlajamäen ala-asteen koulu", type: 11, postal_code: "00710", voting_unit: 15 },
      "03034" => { name: "Pitäjänmäen peruskoulu", type: 11, postal_code: "00370", voting_unit: 7 },
      "03035" => { name: "Porolahden peruskoulu", type: 11, postal_code: "00820", voting_unit: 1 },
      "03036" => { name: "Puistolanraitin ala-asteen koulu", type: 11, postal_code: "00760", voting_unit: 14 },
      "03038" => { name: "Puotilan ala-asteen koulu", type: 11, postal_code: "00910", voting_unit: 2 },
      "03039" => { name: "Itäkeskuksen peruskoulu", type: 11, postal_code: "00900", voting_unit: 2 },
      "03040" => { name: "Roihuvuoren ala-asteen koulu", type: 11, postal_code: "00820", voting_unit: 1 },
      "03041" => { name: "Santahaminan ala-asteen koulu", type: 11, postal_code: "00860", voting_unit: 5 },
      "03043" => { name: "Snellmanin ala-asteen koulu", type: 11, postal_code: "00120", voting_unit: 6 },
      "03044" => { name: "Suomenlinnan ala-asteen koulu", type: 11, postal_code: "00190", voting_unit: 6 },
      "03045" => { name: "Tahvonlahden ala-aste", type: 11, postal_code: "00870", voting_unit: 5 },
      "03046" => { name: "Taivallahden peruskoulu", type: 11, postal_code: "00100", voting_unit: 9 },
      "03047" => { name: "Tapanilan ala-asteen koulu", type: 11, postal_code: "00730", voting_unit: 12 },
      "03048" => { name: "Tehtaankadun ala-asteen koulu", type: 11, postal_code: "00140", voting_unit: 6 },
      "03049" => { name: "Pohjois-Haagan ala-asteen koulu", type: 11, postal_code: "00400", voting_unit: 7 },
      "03050" => { name: "Töölön ala-asteen koulu", type: 11, postal_code: "00250", voting_unit: 9 },
      "03051" => { name: "Vallilan ala-asteen koulu", type: 11, postal_code: "00550", voting_unit: 11 },
      "03053" => { name: "Vartiokylän ala-asteen koulu", type: 11, postal_code: "00950", voting_unit: 2 },
      "03056" => { name: "Yhtenäiskoulu", type: 11, postal_code: "00610", voting_unit: 11 },
      "03059" => { name: "Brändö lågstadieskola", type: 11, postal_code: "00570", voting_unit: 10 },
      "03061" => { name: "Drumsö lågstadieskola", type: 11, postal_code: "00200", voting_unit: 10 },
      "03064" => { name: "Kottby Lågstadieskola", type: 11, postal_code: "00600", voting_unit: 10 },
      "03069" => { name: "Minervaskolan", type: 11, postal_code: "00100", voting_unit: 10 },
      "03071" => { name: "Månsas lågstadieskola", type: 11, postal_code: "00630", voting_unit: 10 },
      "03074" => { name: "Staffansby lågstadieskola", type: 11, postal_code: "00780", voting_unit: 10 },
      "03079" => { name: "Pasilan peruskoulu", type: 11, postal_code: "00520", voting_unit: 11 },
      "03080" => { name: "Kannelmäen peruskoulu", type: 11, postal_code: "00420", voting_unit: 8 },
      "03082" => { name: "Käpylän peruskoulu", type: 11, postal_code: "00610", voting_unit: 11 },
      "03083" => { name: "Jakomäen peruskoulu", type: 11, postal_code: "00770", voting_unit: 14 },
      "03085" => { name: "Kruununhaan yläasteen koulu", type: 11, postal_code: "00170", voting_unit: 6 },
      "03086" => { name: "Laajasalon peruskoulu", type: 11, postal_code: "00840", voting_unit: 5 },
      "03087" => { name: "Suutarinkylän peruskoulu", type: 11, postal_code: "00740", voting_unit: 14 },
      "03088" => { name: "Meilahden yläasteen koulu", type: 11, postal_code: "00270", voting_unit: 9 },
      "03089" => { name: "Myllypuron peruskoulu", type: 11, postal_code: "00920", voting_unit: 2 },
      "03091" => { name: "Pakilan yläasteen koulu", type: 11, postal_code: "00660", voting_unit: 13 },
      "03092" => { name: "Hiidenkiven peruskoulu", type: 11, postal_code: "00730", voting_unit: 12 },
      "03094" => { name: "Pukinmäenkaaren peruskoulu", type: 11, postal_code: "00720", voting_unit: 12 },
      "03096" => { name: "Ressun peruskoulu", type: 11, postal_code: "00180", voting_unit: 6 },
      "03098" => { name: "Puistopolun peruskoulu", type: 11, postal_code: "00980", voting_unit: 4 },
      "03099" => { name: "Vartiokylän yläasteen koulu", type: 11, postal_code: "00910", voting_unit: 2 },
      "03100" => { name: "Vesalan peruskoulu", type: 11, postal_code: "00940", voting_unit: 3 },
      "03101" => { name: "Vuoniityn peruskoulu", type: 11, postal_code: "00980", voting_unit: 4 },
      "03103" => { name: "Malmin peruskoulu", type: 11, postal_code: "00700", voting_unit: 12 },
      "03104" => { name: "Botby grundskola", type: 11, postal_code: "00900", voting_unit: 10 },
      "03105" => { name: "Grundskolan Norsen", type: 11, postal_code: "00130", voting_unit: 10 },
      "03106" => { name: "Hoplaxskolan", type: 11, postal_code: "00330", voting_unit: 10 },
      "03108" => { name: "Åshöjdens grundskola", type: 11, postal_code: "00510", voting_unit: 10 },
      "03111" => { name: "Karviaistien koulu", type: 12, postal_code: "00700", voting_unit: 12 },
      "03112" => { name: "Toivolan koulu", type: 12, postal_code: "00680", voting_unit: 13 },
      "03113" => { name: "Lemmilän koulu", type: 12, postal_code: "05950", voting_unit: 3 },
      "03114" => { name: "Naulakallion koulu", type: 12, postal_code: "00970", voting_unit: 3 },
      "03116" => { name: "Helsingin Juutalainen Yhteiskoulu", type: 11, postal_code: "00100", voting_unit: 6 },
      "03251" => { name: "Keinutien ala-asteen koulu", type: 11, postal_code: "00940", voting_unit: 3 },
      "03252" => { name: "Pihlajiston ala-asteen koulu", type: 11, postal_code: "00710", voting_unit: 15 },
      "03289" => { name: "Malminkartanon ala-asteen koulu", type: 11, postal_code: "00410", voting_unit: 8 },
      "03295" => { name: "Maatullin ala-asteen koulu", type: 11, postal_code: "00750", voting_unit: 14 },
      "03311" => { name: "Suutarilan ala-asteen koulu", type: 11, postal_code: "00740", voting_unit: 14 },
      "03340" => { name: "Zacharias Topeliusskolan", type: 11, postal_code: "00250", voting_unit: 10 },
      "03391" => { name: "Apollon yhteiskoulu", type: 19, postal_code: "00410", voting_unit: 8 },
      "03393" => { name: "Helsingin Suomalainen Yhteiskoulu", type: 19, postal_code: "00320", voting_unit: 7 },
      "03394" => { name: "Helsingin Uusi yhteiskoulu", type: 19, postal_code: "00710", voting_unit: 15 },
      "03395" => { name: "Helsingin yhteislyseo", type: 19, postal_code: "00940", voting_unit: 3 },
      "03396" => { name: "Herttoniemen yhteiskoulu", type: 19, postal_code: "00800", voting_unit: 1 },
      "03398" => { name: "Kulosaaren yhteiskoulu", type: 19, postal_code: "00570", voting_unit: 1 },
      "03400" => { name: "Lauttasaaren yhteiskoulu", type: 19, postal_code: "00200", voting_unit: 6 },
      "03401" => { name: "Maunulan yhteiskoulu - Helsingin matematiikkalukio", type: 19, postal_code: "00630", voting_unit: 13 },
      "03402" => { name: "Munkkiniemen yhteiskoulu", type: 19, postal_code: "00330", voting_unit: 9 },
      "03404" => { name: "Oulunkylän yhteiskoulu", type: 19, postal_code: "00640", voting_unit: 13 },
      "03405" => { name: "Pohjois-Haagan yhteiskoulu", type: 19, postal_code: "00400", voting_unit: 7 },
      "03408" => { name: "Töölön yhteiskoulu", type: 19, postal_code: "00250", voting_unit: 9 },
      "03410" => { name: "Marjatta-koulu", type: 12, postal_code: "00400", voting_unit: 7 },
      "03417" => { name: "Solakallion koulu", type: 12, postal_code: "00680", voting_unit: 13 },
      "03419" => { name: "Paloheinän ala-asteen koulu", type: 11, postal_code: "00670", voting_unit: 13 },
      "03479" => { name: "Siltamäen ala-asteen koulu", type: 11, postal_code: "00740", voting_unit: 14 },
      "03480" => { name: "Koskelan ala-asteen koulu", type: 11, postal_code: "00600", voting_unit: 11 },
      "03510" => { name: "International School of Helsinki", type: 19, postal_code: "00180", voting_unit: 6 },
      "03533" => { name: "Pihkapuiston ala-asteen koulu", type: 11, postal_code: "00410", voting_unit: 8 },
      "03540" => { name: "Elias-koulu", type: 11, postal_code: "00150", voting_unit: 6 },
      "03577" => { name: "Puistolan peruskoulu", type: 11, postal_code: "00760", voting_unit: 14 },
      "03579" => { name: "Laakavuoren ala-aste", type: 11, postal_code: "00970", voting_unit: 3 },
      "03605" => { name: "Hietakummun ala-asteen koulu", type: 11, postal_code: "00700", voting_unit: 12 },
      "03607" => { name: "Degerö lågstadieskola", type: 11, postal_code: "00810", voting_unit: 10 },
      "03614" => { name: "Merilahden peruskoulu", type: 11, postal_code: "00980", voting_unit: 4 },
      "03638" => { name: "Helsingin Kristillinen koulu", type: 11, postal_code: "00720", voting_unit: 12 },
      "03662" => { name: "Ruoholahden ala-asteen koulu", type: 11, postal_code: "00180", voting_unit: 6 },
      "03664" => { name: "Herttoniemenrannan ala-asteen koulu", type: 11, postal_code: "00810", voting_unit: 1 },
      "03672" => { name: "Pikku Huopalahden ala-aste", type: 11, postal_code: "00330", voting_unit: 9 },
      "03674" => { name: "Nordsjö lågstadieskola", type: 11, postal_code: "00980", voting_unit: 10 },
      "03705" => { name: "Torpparinmäen peruskoulu", type: 11, postal_code: "00690", voting_unit: 13 },
      "03716" => { name: "Strömbergin ala-asteen koulu", type: 11, postal_code: "00380", voting_unit: 7 },
      "03723" => { name: "Poikkilaakson ala-asteen koulu", type: 11, postal_code: "00850", voting_unit: 5 },
      "03724" => { name: "Aurinkolahden peruskoulu", type: 11, postal_code: "00980", voting_unit: 4 },
      "03743" => { name: "Arabian peruskoulu", type: 11, postal_code: "00560", voting_unit: 11 },
      "03763" => { name: "Sakarinmäen peruskoulu", type: 11, postal_code: "00890", voting_unit: 5 },
      "03769" => { name: "Latokartanon peruskoulu", type: 11, postal_code: "00790", voting_unit: 15 },
      "03782" => { name: "Helsingin eurooppalainen koulu", type: 19, postal_code: "00120", voting_unit: 6 },
      "03845" => { name: "Kalasataman peruskolu", type: 11, postal_code: "00540", voting_unit: 6 },
      "03852" => { name: "Jätkäsaaren peruskoulu", type: 11, postal_code: "00220", voting_unit: 6 },
      "03861" => { name: "Helsingin Montessorikoulu", type: 11, postal_code: "00800", voting_unit: 1 },
      "05676" => { name: "Östersundom skola", type: 11, postal_code: "00890", voting_unit: 10 },
      "10016" => { name: "Yrkesinstitutet Prakticum", type: 21, postal_code: "00560", voting_unit: nil },
      "10079" => { name: "Keskuspuiston ammattiopisto", type: 22, postal_code: "00280", voting_unit: nil },
      "10086" => { name: "Business College Helsinki", type: 21, postal_code: "00520", voting_unit: nil },
      "10105" => { name: "Stadin ammattiopisto", type: 21, postal_code: "00550", voting_unit: nil },
      "10120" => { name: "Perho Liiketalousopisto", type: 21, postal_code: "00100", voting_unit: nil }
    }.freeze

    def self.metadata_for_school(school_code)
      MAPPING[school_code]
    end

    def self.postal_code_for_school(school_code)
      data = metadata_for_school(school_code)
      return nil unless data

      data[:postal_code]
    end

    def self.voting_unit_for_school(school_code)
      data = metadata_for_school(school_code)
      return nil unless data

      data[:voting_unit]
    end
  end
end
