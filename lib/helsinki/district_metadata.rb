# frozen_string_literal: true

module Helsinki
  class DistrictMetadata
    MAPPING = {
      # Southern / Eteläinen
      1 => %w(00100 00120 00130 00140 00150 00160 00170 00180 00190 00200 00210 00220 00260),
      # Western / Läntinen
      2 => %w(00250 00270 00280 00290 00300 00310 00320 00330 00340 00350 00360 00370 00380 00390 00400 00410 00420 00430 00440),
      # Central / Keskinen
      3 => %w(00230 00240 00500 00510 00520 00530 00540 00550 00580 00600 00610),
      # Northern / Pohjoinen
      4 => %w(00620 00630 00640 00650 00660 00670 00680 00690),
      # Northeastern / Koillinen
      5 => %w(00560 00700 00710 00720 00730 00740 00750 00760 00770 00780 00790),
      # Southeastern / Kaakkoinen
      6 => %w(00570 00590 00800 00810 00820 00830 00840 00850 00860 00870 00880),
      # Eastern / Itäinen
      7 => %w(00900 00910 00920 00930 00940 00950 00960 00970 00980 00990),
      # Östersundom
      8 => %w(00890)
    }.freeze

    def self.subdivision_for_postal_code(postal_code)
      MAPPING.each do |subdivision, codes|
        return subdivision if codes.include?(postal_code)
      end
    end

    def self.subdivision_names
      {
        1 => I18n.t("southern", scope: "helsinki.map.districts"),
        2 => I18n.t("western", scope: "helsinki.map.districts"),
        3 => I18n.t("central", scope: "helsinki.map.districts"),
        4 => I18n.t("northern", scope: "helsinki.map.districts"),
        5 => I18n.t("northeastern", scope: "helsinki.map.districts"),
        6 => I18n.t("southeastern", scope: "helsinki.map.districts"),
        7 => I18n.t("eastern", scope: "helsinki.map.districts"),
        8 => I18n.t("ostersundom", scope: "helsinki.map.districts")
      }
    end

    def self.subdivision_code_to_name(code)
      subdivision_names[code]
    end
  end
end
