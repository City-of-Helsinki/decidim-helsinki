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
    # NOTE: This list only contains the Helsinki schools that have elementary
    #       level.
    MAPPING = {
      "01000" => {name: "Testilukio", type: 15, postal_code: "90800"},
      "03002" => {name: "Aleksis Kiven peruskoulu", type: 11, postal_code: "00510"},
      "03004" => {name: "Haagan peruskoulu", type: 11, postal_code: "00320"},
      "03005" => {name: "Hertsikan ala-aste", type: 11, postal_code: "00800"},
      "03010" => {name: "Kaisaniemen ala-asteen koulu", type: 11, postal_code: "00100"},
      "03011" => {name: "Kallion ala-asteen koulu", type: 11, postal_code: "00530"},
      "03013" => {name: "Katajanokan ala-asteen koulu", type: 11, postal_code: "00160"},
      "03014" => {name: "Konalan ala-asteen koulu", type: 11, postal_code: "00390"},
      "03015" => {name: "Kontulan ala-asteen koulu", type: 11, postal_code: "00940"},
      "03016" => {name: "Kulosaaren ala-asteen koulu", type: 11, postal_code: "00570"},
      "03020" => {name: "Maunulan ala-asteen koulu", type: 11, postal_code: "00630"},
      "03021" => {name: "Meilahden ala-asteen koulu", type: 11, postal_code: "00270"},
      "03022" => {name: "Mellunmäen ala-asteen koulu", type: 11, postal_code: "00970"},
      "03023" => {name: "Metsolan ala-asteen koulu", type: 11, postal_code: "00680"},
      "03024" => {name: "Munkkiniemen ala-asteen koulu", type: 11, postal_code: "00330"},
      "03025" => {name: "Munkkivuoren ala-asteen koulu", type: 11, postal_code: "00350"},
      "03026" => {name: "Lauttasaaren ala-asteen koulu", type: 11, postal_code: "00200"},
      "03030" => {name: "Oulunkylän ala-asteen koulu", type: 11, postal_code: "00640"},
      "03032" => {name: "Pakilan ala-asteen koulu", type: 11, postal_code: "00660"},
      "03033" => {name: "Pihlajamäen ala-asteen koulu", type: 11, postal_code: "00710"},
      "03034" => {name: "Pitäjänmäen peruskoulu", type: 11, postal_code: "00370"},
      "03035" => {name: "Porolahden peruskoulu", type: 11, postal_code: "00820"},
      "03036" => {name: "Puistolanraitin ala-asteen koulu", type: 11, postal_code: "00760"},
      "03038" => {name: "Puotilan ala-asteen koulu", type: 11, postal_code: "00910"},
      "03039" => {name: "Itäkeskuksen peruskoulu", type: 11, postal_code: "00900"},
      "03040" => {name: "Roihuvuoren ala-asteen koulu", type: 11, postal_code: "00820"},
      "03041" => {name: "Santahaminan ala-asteen koulu", type: 11, postal_code: "00860"},
      "03043" => {name: "Snellmanin ala-asteen koulu", type: 11, postal_code: "00120"},
      "03044" => {name: "Suomenlinnan ala-asteen koulu", type: 11, postal_code: "00190"},
      "03045" => {name: "Tahvonlahden ala-aste", type: 11, postal_code: "00870"},
      "03046" => {name: "Taivallahden peruskoulu", type: 11, postal_code: "00100"},
      "03047" => {name: "Tapanilan ala-asteen koulu", type: 11, postal_code: "00730"},
      "03048" => {name: "Tehtaankadun ala-asteen koulu", type: 11, postal_code: "00140"},
      "03049" => {name: "Pohjois-Haagan ala-asteen koulu", type: 11, postal_code: "00400"},
      "03050" => {name: "Töölön ala-asteen koulu", type: 11, postal_code: "00250"},
      "03051" => {name: "Vallilan ala-asteen koulu", type: 11, postal_code: "00550"},
      "03053" => {name: "Vartiokylän ala-asteen koulu", type: 11, postal_code: "00950"},
      "03056" => {name: "Yhtenäiskoulu", type: 11, postal_code: "00610"},
      "03079" => {name: "Pasilan peruskoulu", type: 11, postal_code: "00520"},
      "03080" => {name: "Kannelmäen peruskoulu", type: 11, postal_code: "00420"},
      "03082" => {name: "Käpylän peruskoulu", type: 11, postal_code: "00610"},
      "03083" => {name: "Jakomäen peruskoulu", type: 11, postal_code: "00770"},
      "03085" => {name: "Kruununhaan yläasteen koulu", type: 11, postal_code: "00170"},
      "03086" => {name: "Laajasalon peruskoulu", type: 11, postal_code: "00840"},
      "03087" => {name: "Suutarinkylän peruskoulu", type: 11, postal_code: "00740"},
      "03088" => {name: "Meilahden yläasteen koulu", type: 11, postal_code: "00270"},
      "03089" => {name: "Myllypuron peruskoulu", type: 11, postal_code: "00920"},
      "03091" => {name: "Pakilan yläasteen koulu", type: 11, postal_code: "00660"},
      "03092" => {name: "Hiidenkiven peruskoulu", type: 11, postal_code: "00730"},
      "03094" => {name: "Pukinmäenkaaren peruskoulu", type: 11, postal_code: "00720"},
      "03096" => {name: "Ressun peruskoulu", type: 11, postal_code: "00180"},
      "03098" => {name: "Puistopolun peruskoulu", type: 11, postal_code: "00980"},
      "03099" => {name: "Vartiokylän yläasteen koulu", type: 11, postal_code: "00910"},
      "03100" => {name: "Vesalan peruskoulu", type: 11, postal_code: "00940"},
      "03101" => {name: "Vuoniityn peruskoulu", type: 11, postal_code: "00980"},
      "03103" => {name: "Malmin peruskoulu", type: 11, postal_code: "00700"},
      "03116" => {name: "Helsingin Juutalainen Yhteiskoulu", type: 11, postal_code: "00100"},
      "03251" => {name: "Keinutien ala-asteen koulu", type: 11, postal_code: "00940"},
      "03252" => {name: "Pihlajiston ala-asteen koulu", type: 11, postal_code: "00710"},
      "03289" => {name: "Malminkartanon ala-asteen koulu", type: 11, postal_code: "00410"},
      "03295" => {name: "Maatullin ala-asteen koulu", type: 11, postal_code: "00750"},
      "03311" => {name: "Suutarilan ala-asteen koulu", type: 11, postal_code: "00740"},
      "03391" => {name: "Apollon yhteiskoulu", type: 19, postal_code: "00410"},
      "03393" => {name: "Helsingin Suomalainen Yhteiskoulu", type: 19, postal_code: "00320"},
      "03394" => {name: "Helsingin Uusi yhteiskoulu", type: 19, postal_code: "00710"},
      "03395" => {name: "Helsingin yhteislyseo", type: 19, postal_code: "00940"},
      "03396" => {name: "Herttoniemen yhteiskoulu", type: 19, postal_code: "00800"},
      "03398" => {name: "Kulosaaren yhteiskoulu", type: 19, postal_code: "00570"},
      "03400" => {name: "Lauttasaaren yhteiskoulu", type: 19, postal_code: "00200"},
      "03401" => {name: "Maunulan yhteiskoulu - Helsingin matematiikkalukio", type: 19, postal_code: "00630"},
      "03402" => {name: "Munkkiniemen yhteiskoulu", type: 19, postal_code: "00330"},
      "03404" => {name: "Oulunkylän yhteiskoulu", type: 19, postal_code: "00640"},
      "03405" => {name: "Pohjois-Haagan yhteiskoulu", type: 19, postal_code: "00400"},
      "03408" => {name: "Töölön yhteiskoulu", type: 19, postal_code: "00250"},
      "03419" => {name: "Paloheinän ala-asteen koulu", type: 11, postal_code: "00670"},
      "03479" => {name: "Siltamäen ala-asteen koulu", type: 11, postal_code: "00740"},
      "03480" => {name: "Koskelan ala-asteen koulu", type: 11, postal_code: "00600"},
      "03510" => {name: "International School of Helsinki", type: 19, postal_code: "00180"},
      "03533" => {name: "Pihkapuiston ala-asteen koulu", type: 11, postal_code: "00410"},
      "03540" => {name: "Elias-koulu", type: 11, postal_code: "00150"},
      "03577" => {name: "Puistolan peruskoulu", type: 11, postal_code: "00760"},
      "03579" => {name: "Laakavuoren ala-aste", type: 11, postal_code: "00970"},
      "03605" => {name: "Hietakummun ala-asteen koulu", type: 11, postal_code: "00700"},
      "03614" => {name: "Merilahden peruskoulu", type: 11, postal_code: "00980"},
      "03638" => {name: "Helsingin Kristillinen koulu", type: 11, postal_code: "00720"},
      "03662" => {name: "Ruoholahden ala-asteen koulu", type: 11, postal_code: "00180"},
      "03664" => {name: "Herttoniemenrannan ala-asteen koulu", type: 11, postal_code: "00810"},
      "03672" => {name: "Pikku Huopalahden ala-aste", type: 11, postal_code: "00330"},
      "03705" => {name: "Torpparinmäen peruskoulu", type: 11, postal_code: "00690"},
      "03716" => {name: "Strömbergin ala-asteen koulu", type: 11, postal_code: "00380"},
      "03723" => {name: "Poikkilaakson ala-asteen koulu", type: 11, postal_code: "00850"},
      "03724" => {name: "Aurinkolahden peruskoulu", type: 11, postal_code: "00980"},
      "03743" => {name: "Arabian peruskoulu", type: 11, postal_code: "00560"},
      "03763" => {name: "Sakarinmäen peruskoulu", type: 11, postal_code: "00890"},
      "03769" => {name: "Latokartanon peruskoulu", type: 11, postal_code: "00790"},
      "03782" => {name: "Helsingin eurooppalainen koulu", type: 19, postal_code: "00120"},
      "03845" => {name: "Kalasataman peruskolu", type: 11, postal_code: "00540"},
      "03852" => {name: "Jätkäsaaren peruskoulu", type: 11, postal_code: "00220"},
      "03861" => {name: "Helsingin Montessorikoulu", type: 11, postal_code: "00800"},
    }

    def self.metadata_for_school(school_code)
      MAPPING[school_code]
    end

    def self.postal_code_for_school(school_code)
      data = metadata_for_school(school_code)
      return nil unless data

      data[:postal_code]
    end
  end
end
