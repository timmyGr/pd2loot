require 'sinatra'
require 'sinatra/reloader'
require 'json'

$translations = {
  "fireresist" => "Fire Resist +val%",
  "coldresist" => "Cold Resist +val%",
  "lightresist" => "Lightning Resist +val%",
  "poisonresist" => "Poison Resist +val%",
  "res-fire" => "Fire Resist +val%",
  "res-pois" => "Poison Resist +val%",
  "res-ltng" => "Lightning Resist +val%",
  "res-cold" => "Cold Resist +val%",
  "res-all" => "+val To All Skills",
  "vit" => "+val To Vitality",
  "str" => "+val To Strength",
  "dex" => "+val To Dexterity",
  "mag%" => "val% Better Chance of Getting Magic Items",
  "item_magicbonus" => "val% Better Chance of Getting Magic Items",
  "gold%" => "val% Extra Gold From Monsters",
  "maxmana" => "+val to Mana",
  "maxhp" => "+val To Life",
  "lifesteal" => "val% Life Stolen Per Hit",
  "item_fastermovevelocity" => "val% Faster Run/Walk",
  "move2" => "val% Faster Run/Walk",
  "move3" => "val% Faster Run/Walk",
  "sock" => "Socketed val",
  "allskills" => "+val To All Skills",
  "Negates % of Enemy Cold Resistance" => "-val% to Enemy Cold Resistance",
  "Negates % of Enemy Lightning Resistance" => "-val% to Enemy Lightning Resistance",
  "Negates % of Enemy Fire Resistance" => "-val% to Enemy Fire Resistance",
  "Negates % of Enemy Poison Resistance" => "-val% to Enemy Poison Resistance",
  "mana%" => "Increased Maximum Mana val%",
  "ease" => "Requirements val%",
  "thorns" => "Attack takes damage of val",
  "fireskill" => "+val to Fire Skills",
  "att%" => "val% Bonus To Attack Rating",
  "manasteal" => "val% Mana Stolen Per Hit",
  "light" => "+val To Light Radius",
  "res-pois-len" => "Poison Length Reduced By val%",
  "att" => "+val To Attack Rating",
  "mana-kill" => "+val To Mana After Each Kill",
  "balance1" => "+val% Faster Hit Recovery",
  "balance2" => "+val% Faster Hit Recovery",
  "balance3" => "+val% Faster Hit Recovery",
  "mana" => "+val to Mana",
  "reduces vendor prices" => "Reduces All Vendor Prices val%",
  "dexterity" => "+val to Dexterity",
  "red-dmg" => "Physical Damage Taken Reduced By val",
  "red-mag" => "Magical Damage Taken Reduced By val",
  "regen" => "Replenish Life +val",
  "hp" => "+val to Life",
  "regen-mana" => "Regenerate Mana val%",
  "maxstamina" => "+val to Maximum Stamina",
  "bar" => "+val to Barbarian Skills",
  "cast2" => "val% Faster Cast Rate",
  "cast3" => "val% Faster Cast Rate",
  "enr" => "Increased Maximum Mana val%",
  "ignore-ac" => "Ignore Target's Defense",
  "deadly" => "val% Deadly Strike",
  "tohit" => "+val to Attack Rating",
  "maxdamage" => "+val To Maximum Damage",
  "item_goldbonus" => "val% Extra Gold From Monsters",
  "manadrainmindam" => "val% Mana Stolen Per Hit",
  "mindamage" => "+val to Minimum Damage",
  "hpregen" => "Replenish Life +val",
  "swing2" => "val% Increased Attack Speed",
  "dmg%" => "val% Enhanced Damage",
  "All Assassin Skills" => "+val To Assassin Skills",
  "item_replenish_durability" => "Repairs val Durability in 20 seconds",
  "magicarrow" => "Fires Magic Arrows",
  "energy" => "+val To Energy",
  "nofreeze" => "Cannot Be Frozen",
  "freeze" => "Freezes Target +val",
  "cold skills" => "+val to Cold Skills",
  "item_maxdamage_percent" => "+val% Enhanced Damage",
  "item_manaafterkill" => "+val to Mana After Each Kill",
  "strength" => "+val to Strength",
  "item_fastercastrate" => "+val% Faster Cast Rate",
  "lifedrainmindam" => "val% Life Stolen Per Hit",
  "item_halffreezeduration" => "Half Freeze Duration",
  "dmg-to-mana" => "val% Damage Taken Gained as Mana When Hit",
  "extra-pois" => "+val% to Poison Skill Damage",
  "dmg-demon" => "+val% Damage to Demons",
  "crush" => "val% Chance of Crushing Blow",
  "red-dmg%" => "Physical Damage Taken Reduced By val%",
  "item_lightradius" => "+val to Light Radius",
  "item_armor_percent" => "+val% Enhanced Defense",
  "block1" => "+val% Faster Block Rate",
  "block2" => "+val% Faster Block Rate",
  "block3" => "+val% Faster Block Rate",
  "stam" => "+val Maxium Stamine",
  "res-fire-max" => "+val% to Maximum Fire Resist",
  "regen-stam" => "Heal Stamine Plus val%",
  "reduce-ac" => "-val% Target Defense",
  "cast1" => "+val% Faster Cast Rate",
}

$ranges = {
  "Poison Damage" => "Adds min-max Poison Damage", # what to do with this?
  "Fire Damage" => "Adds min-max Fire Damage",
  "Cold Damage" => "Adds min-max Cold Damage",
  "Lightning Damage" => "Adds min-max Lightning Damage",
  "Normal Damage Modifier" => "Adds min-max Damage"
}

$skip = [
  "ac",
  "dur",
  "stamdrain",
  "poisonmaxdam", # double check
  "poisonmindam", # double check
  "poisonlength", # double check
  "poison_count", # double check
  "firemindam",
  "firemaxdam",
  "splash",
  "fire-max",
  "Proc Skill on Hit",
  "secondary_maxdamage",
  "item_throw_maxdamage",
  "secondary_mindamage",
  "item_throw_mindamage",
  "corrupted", # add this to the UI
  "corruptor", #?
  "oskill",
  "Charged Skill",
  "item_mindamage_percent",
  "coldmindam", # add these,
  "coldmaxdam", # add these,
  "coldlength",
  "lightmindam",
  "lightmaxdam"
]

get '/' do
  file = File.read('tests/yeowoh_UncleMind.txt')
  @data = JSON.parse(file).select { |d| d.key?("name") }

  @data.map do |m|
    if m["stats"].kind_of?(Array)
      m["stats"].map do |s|
        s["readable"] = translator(s)
      end
    end
  end

  erb :index
end

def translator(stat)
  if $skip.include? stat["name"]
    nil
  elsif $ranges.include? stat["name"]
    $ranges[stat["name"]].gsub(/min|max/, "min" => stat["min"].to_s, "max" => stat["max"].to_s)
  elsif stat["name"] == "item_addskill_tab"
    "+#{stat["value"]} to #{stat["skill"]}"
  else
    s = $translations[stat["name"]].gsub(/val/, stat["value"].to_s)

    if stat["range"]
      s += " [#{stat["range"]["min"]} - #{stat["range"]["max"]}]"
    end

    s
  end
end