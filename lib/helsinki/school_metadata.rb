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
    # NOTE: Currently this list is not completed yet, pending for information.
    MAPPING = {
      "00004" => {name: "Alppilan lukio", type: 15, postal_code: "00000"},
      "00081" => {name: "Helsingin luonnontiedelukio", type: 15, postal_code: "00000"},
      "00082" => {name: "Ressun lukio", type: 15, postal_code: "00000"},
      "00083" => {name: "Helsingin normaalilyseo", type: 19, postal_code: "00000"},
      "00084" => {name: "Helsingin ranskalais-suomalainen koulu", type: 19, postal_code: "00000"},
      "00085" => {name: "Helsingin saksalainen koulu", type: 19, postal_code: "00000"},
      "00087" => {name: "Suomalais-venäläinen koulu", type: 19, postal_code: "00000"},
      "00088" => {name: "Helsingin kuvataidelukio", type: 15, postal_code: "00000"},
      "00089" => {name: "Sibelius-lukio", type: 15, postal_code: "00000"},
      "00255" => {name: "Kallion lukio", type: 15, postal_code: "00000"},
      "00316" => {name: "Eiran aikuislukio", type: 15, postal_code: "00000"},
      "00394" => {name: "Englantilainen koulu", type: 19, postal_code: "00000"},
      "01134" => {name: "Sanoma Akatemia", type: 23, postal_code: "00000"},
      "01154" => {name: "Rakennusteollisuuden koulutuskeskus RATEKO", type: 23, postal_code: "00000"},
      "01164" => {name: "H:gin Maalariammattikoulu", type: 21, postal_code: "00000"},
      "03002" => {name: "Aleksis Kiven peruskoulu", type: 11, postal_code: "00000"},
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
