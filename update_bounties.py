#!/usr/bin/env python3
import json
import re
from datetime import datetime

def update_character_format(character):
    """Atualiza um personagem para o novo formato"""
    
    # Mapeamento de ataques baseado no tipo de personagem
    attacks_map = {
        "Gol D. Roger": ["Divine Departure", "Roger's Slash", "King's Strike", "Conqueror's Blade"],
        "Edward Newgate": ["Gura Gura no Mi: Quake", "Gura Gura no Mi: Tremor", "Gura Gura no Mi: Shockwave", "Gura Gura no Mi: Tsunami"],
        "Kaido": ["Boro Breath", "Thunder Bagua", "Dragon Twister", "Ragnaraku"],
        "Charlotte Linlin": ["Soru Soru no Mi: Soul Pocus", "Soru Soru no Mi: Homie Creation", "Soru Soru no Mi: Life Drain", "Napoleon Slash"],
        "Shanks": ["Divine Departure", "Gryphon Slash", "Conqueror's Strike", "Haki Burst"],
        "Marshall D. Teach": ["Darkness Vortex", "Black Hole", "Dark Matter", "Gravity Pull"],
        "Dracule Mihawk": ["Yoru Slash", "World's Strongest Slash", "Hawk Eye Strike", "Cross Guild Cut"],
        "Buggy": ["Chop Chop Cannon", "Buggy Ball", "Chop Chop Festival", "Buggy Star"],
        "Monkey D. Luffy": ["Gomu Gomu no Pistol", "Gear 5: Giant Fist", "Gomu Gomu no Red Hawk", "Gear 5: White Star Gun"],
        "Trafalgar D. Water Law": ["Room", "Shambles", "Gamma Knife", "Takt"],
        "Eustass Kid": ["Magnetic Force", "Punk Gibson", "Assign", "Damned Punk"],
        "Loki": ["Giant Strike", "Elbaf Power", "Thunder Attack", "Giant Slash"],
        "Crocodile": ["Desert Spada", "Ground Death", "Sables", "Desert Storm"],
        "Boa Hancock": ["Mero Mero no Mellow", "Slave Arrow", "Pistol Kiss", "Perfume Femur"],
        "King": ["Dragon Twister", "Imperial Flaming Wings", "Dragon Smaher", "Tempered Fire"],
        "Marco": ["Phoenix Brand", "Blue Bird", "Phoenix Fire", "Regeneration"],
        "Queen": ["Brachio Bomber", "Ice Oni", "Plague Rounds", "Queen's Laser"],
        "Roronoa Zoro": ["Santoryu", "Asura", "Dragon Twister", "King of Hell"],
        "Jinbe": ["Fishman Karate", "Vagabond Drill", "Shark Skin", "Water Shot"],
        "Charlotte Katakuri": ["Mochi Mochi no Mochi", "Mochi Thrust", "Mochi Mochi no Power Mochi", "Mochi Mochi no Spear"],
        "Vinsmoke Sanji": ["Diable Jambe", "Hell Memories", "Ifrit Jambe", "Concasser"],
        "Jack": ["Mammoth", "Drought", "Tusks", "Trunk"],
        "Charlotte Smoothie": ["Squeeze", "Juice Extraction", "Smoothie Slash", "Fruit Power"],
        "Nico Robin": ["Mil Fleur", "Gigantesco Mano", "Dos Fleur", "Tres Fleur"],
        "Charlotte Cracker": ["Biscuit Soldiers", "Thousand Arms", "Biscuit Shield", "Cracker Slash"],
        "Charlotte Perospero": ["Candy Wall", "Candy Arrow", "Candy Rain", "Candy Prison"],
        "Sabo": ["Hiken", "Dragon Claw", "Flame Dragon", "Fire Fist"],
        "Charlotte Snack": ["Sweet Commander", "Snack Attack", "Candy Strike", "Sweet Power"],
        "Portgas D. Ace": ["Hiken", "Dai Enkai", "Higan", "Fire Fist"],
        "Little Oars Jr.": ["Giant Strike", "Oars Attack", "Giant Punch", "Oars Power"],
        "Who's-Who": ["Fang Over Fang", "Saber Tiger", "Who's Who Slash", "Tiger Claw"],
        "Chinjao": ["Hasshoken", "Drill", "Headbutt", "Chinjao Strike"],
        "Izou": ["Pistol", "Gunpowder", "Izou Shot", "Pistol Dance"],
        "Franky": ["Franky Radical Beam", "Coup de Vent", "Strong Right", "Franky Boxing"],
        "Brook": ["Soul Solid", "Yomi Yomi no Mi", "Soul King", "Brook Slash"],
        "Pedro": ["Electro", "Mink Combat", "Pedro Strike", "Lightning"],
        "Nami": ["Clima-Tact", "Thunder", "Tornado", "Weather Control"],
        "Scratchmen Apoo": ["Oto Oto no Mi", "Sound Attack", "Apoo Strike", "Music Power"],
        "Capone Bege": ["Shiro Shiro no Mi", "Castle", "Bege Attack", "Castle Power"],
        "Donquixote Doflamingo": ["Ito Ito no Mi", "Birdcage", "Overheat", "Parasite"],
        "Basil Hawkins": ["Wara Wara no Mi", "Straw Man", "Hawkins Attack", "Voodoo"],
        "Jewelry Bonney": ["Toshi Toshi no Mi", "Age Manipulation", "Bonney Attack", "Time Power"],
        "Gecko Moria": ["Kage Kage no Mi", "Shadow Asgard", "Doppelman", "Shadow Power"],
        "Lindbergh": ["Revolutionary", "Lindbergh Attack", "Freedom Strike", "Revolution"],
        "Charlotte Oven": ["Netsu Netsu no Mi", "Heat", "Oven Attack", "Hot Power"],
        "Charlotte Daifuku": ["Hoya Hoya no Mi", "Genie", "Daifuku Attack", "Wish Power"],
        "Caesar Clown": ["Gasu Gasu no Mi", "Shinokuni", "Caesar Attack", "Gas Power"],
        "Bartholomew Kuma": ["Nikyu Nikyu no Mi", "Ursus Shock", "Kuma Attack", "Paw Power"],
        "Morley": ["Revolutionary", "Giant", "Morley Attack", "Freedom"],
        "Page One": ["Ryu Ryu no Mi", "Spinosaurus", "Page One Attack", "Dino Power"],
        "X Drake": ["Ryu Ryu no Mi", "Allosaurus", "Drake Attack", "Dino Power"],
        "Sai": ["Hasshoken", "Sai Attack", "Happo Navy", "Sai Strike"]
    }
    
    # Mapeamento de armas
    weapons_map = {
        "Gol D. Roger": ["Ace (Espada)", "Roger's Saber"],
        "Edward Newgate": ["Bisento Murakumogiri"],
        "Kaido": ["Kanabo (Clube de Ferro)"],
        "Charlotte Linlin": ["Napoleon (Espada Viva)", "Zeus (Nuvem Viva)", "Prometheus (Fogo Vivo)"],
        "Shanks": ["Gryphon (Espada)"],
        "Marshall D. Teach": ["Claws", "Darkness Powers"],
        "Dracule Mihawk": ["Yoru (Espada Negra)"],
        "Buggy": ["Buggy Balls", "Knives"],
        "Monkey D. Luffy": ["Rubber Body", "Gear Transformations"],
        "Trafalgar D. Water Law": ["Kikoku (Espada)"],
        "Eustass Kid": ["Magnetic Powers", "Metal Objects"],
        "Loki": ["Giant Weapons"],
        "Crocodile": ["Hook Hand"],
        "Boa Hancock": ["Mero Mero no Mi Powers"],
        "King": ["Katana"],
        "Marco": ["Phoenix Powers"],
        "Queen": ["Plague Weapons"],
        "Roronoa Zoro": ["Wado Ichimonji", "Sandai Kitetsu", "Enma"],
        "Jinbe": ["Fishman Karate"],
        "Charlotte Katakuri": ["Mochi Powers"],
        "Vinsmoke Sanji": ["Legs", "Raidsuit"],
        "Jack": ["Mammoth Form"],
        "Charlotte Smoothie": ["Sword"],
        "Nico Robin": ["Hana Hana no Mi Powers"],
        "Charlotte Cracker": ["Biscuit Soldiers"],
        "Charlotte Perospero": ["Candy Powers"],
        "Sabo": ["Pipe", "Mera Mera no Mi"],
        "Charlotte Snack": ["Sweet Powers"],
        "Portgas D. Ace": ["Mera Mera no Mi"],
        "Little Oars Jr.": ["Giant Body"],
        "Who's-Who": ["Saber Tiger Form"],
        "Chinjao": ["Head", "Hasshoken"],
        "Izou": ["Pistols"],
        "Franky": ["Cyborg Body", "Weapons"],
        "Brook": ["Soul Solid (Espada)"],
        "Pedro": ["Electro", "Mink Powers"],
        "Nami": ["Clima-Tact"],
        "Scratchmen Apoo": ["Oto Oto no Mi Powers"],
        "Capone Bege": ["Castle Form"],
        "Donquixote Doflamingo": ["Ito Ito no Mi Powers"],
        "Basil Hawkins": ["Straw Man", "Voodoo"],
        "Jewelry Bonney": ["Toshi Toshi no Mi Powers"],
        "Gecko Moria": ["Kage Kage no Mi Powers"],
        "Lindbergh": ["Revolutionary Weapons"],
        "Charlotte Oven": ["Netsu Netsu no Mi Powers"],
        "Charlotte Daifuku": ["Genie"],
        "Caesar Clown": ["Gasu Gasu no Mi Powers"],
        "Bartholomew Kuma": ["Nikyu Nikyu no Mi Powers"],
        "Morley": ["Giant Body"],
        "Page One": ["Spinosaurus Form"],
        "X Drake": ["Allosaurus Form"],
        "Sai": ["Hasshoken"]
    }
    
    # Mapeamento de descrições
    descriptions_map = {
        "Gol D. Roger": "The legendary Pirate King who conquered the Grand Line and found the One Piece, inspiring the Great Pirate Era",
        "Edward Newgate": "The Strongest Man in the World and former captain of the Whitebeard Pirates, known for his immense power and fatherly nature",
        "Kaido": "The Strongest Creature in the World and captain of the Beasts Pirates, known for his dragon form and indestructible body",
        "Charlotte Linlin": "The Queen of Totoland and captain of the Big Mom Pirates, known for her soul manipulation powers and massive family",
        "Shanks": "The captain of the Red Hair Pirates and one of the Four Emperors, known for his incredible Haki mastery and missing arm",
        "Marshall D. Teach": "The captain of the Blackbeard Pirates and one of the Four Emperors, known for his darkness powers and ability to steal Devil Fruits",
        "Dracule Mihawk": "The World's Greatest Swordsman and member of the Cross Guild, known for his incredible sword skills and hawk-like eyes",
        "Buggy": "The captain of the Cross Guild and former member of Roger's crew, known for his chop-chop powers and comedic nature",
        "Monkey D. Luffy": "The captain of the Straw Hat Pirates and the man who will become the Pirate King, known for his rubber powers and Gear 5 transformation",
        "Trafalgar D. Water Law": "The captain of the Heart Pirates and a Super Rookie, known for his surgical powers and alliance with Luffy",
        "Eustass Kid": "The captain of the Kid Pirates and a Super Rookie, known for his magnetic powers and rivalry with Luffy",
        "Loki": "The prince of Elbaf and a powerful giant warrior, known for his immense strength and connection to the giants",
        "Crocodile": "The former Warlord and leader of Baroque Works, known for his sand powers and desert kingdom",
        "Boa Hancock": "The Pirate Empress and captain of the Kuja Pirates, known for her beauty and love powers",
        "King": "The All-Star of the Beasts Pirates and right-hand man of Kaido, known for his ancient zoan powers and fire abilities",
        "Marco": "The Phoenix and former first division commander of the Whitebeard Pirates, known for his regeneration powers",
        "Queen": "The All-Star of the Beasts Pirates and Kaido's left-hand man, known for his plague powers and mechanical body",
        "Roronoa Zoro": "The swordsman of the Straw Hat Pirates and Luffy's right-hand man, known for his three-sword style and ambition to become the world's greatest swordsman",
        "Jinbe": "The helmsman of the Straw Hat Pirates and former Warlord, known for his fishman karate and connection to the sea",
        "Charlotte Katakuri": "The Sweet Commander of the Big Mom Pirates and Linlin's strongest son, known for his mochi powers and future sight",
        "Vinsmoke Sanji": "The cook of the Straw Hat Pirates and former prince of Germa, known for his black leg style and chivalry",
        "Jack": "The All-Star of the Beasts Pirates and Kaido's third commander, known for his mammoth powers and durability",
        "Charlotte Smoothie": "The Sweet Commander of the Big Mom Pirates and Linlin's daughter, known for her juice extraction powers",
        "Nico Robin": "The archaeologist of the Straw Hat Pirates and former Baroque Works agent, known for her flower powers and knowledge of the Void Century",
        "Charlotte Cracker": "The Sweet Commander of the Big Mom Pirates and Linlin's son, known for his biscuit soldier powers",
        "Charlotte Perospero": "The Sweet Commander of the Big Mom Pirates and Linlin's eldest son, known for his candy powers",
        "Sabo": "The Chief of Staff of the Revolutionary Army and Luffy's sworn brother, known for his fire powers and amnesia",
        "Charlotte Snack": "The former Sweet Commander of the Big Mom Pirates and Linlin's son, known for his sweet powers",
        "Portgas D. Ace": "The former second division commander of the Whitebeard Pirates and Luffy's sworn brother, known for his fire powers and sacrifice",
        "Little Oars Jr.": "The giant pirate and ally of the Whitebeard Pirates, known for his immense size and loyalty to Whitebeard",
        "Who's-Who": "The Headliner of the Beasts Pirates and former CP9 agent, known for his saber tiger powers and past",
        "Chinjao": "The leader of the Happo Navy and grandfather of Sai, known for his drill head and haki mastery",
        "Izou": "The sixteenth division commander of the Whitebeard Pirates and former Kozuki retainer, known for his gun skills and loyalty",
        "Franky": "The shipwright of the Straw Hat Pirates and former gang leader, known for his cyborg body and cola-powered weapons",
        "Brook": "The musician of the Straw Hat Pirates and former Rumbar Pirates captain, known for his skeleton form and soul powers",
        "Pedro": "The former captain of the Nox Pirates and ally of the Straw Hat Pirates, known for his electro powers and sacrifice",
        "Nami": "The navigator of the Straw Hat Pirates and former thief, known for her weather control and navigation skills",
        "Scratchmen Apoo": "The captain of the On Air Pirates and Super Rookie, known for his music powers and betrayal",
        "Capone Bege": "The captain of the Fire Tank Pirates and Super Rookie, known for his castle powers and family",
        "Donquixote Doflamingo": "The former Warlord and captain of the Donquixote Pirates, known for his string powers and underworld connections",
        "Basil Hawkins": "The captain of the Hawkins Pirates and Super Rookie, known for his straw man powers and fortune telling",
        "Jewelry Bonney": "The captain of the Bonney Pirates and Super Rookie, known for her age manipulation powers and mysterious past",
        "Gecko Moria": "The former Warlord and captain of the Thriller Bark Pirates, known for his shadow powers and zombie army",
        "Lindbergh": "The commander of the Revolutionary Army and inventor, known for his technological skills and freedom fighting",
        "Charlotte Oven": "The Sweet Commander of the Big Mom Pirates and Linlin's son, known for his heat powers",
        "Charlotte Daifuku": "The Sweet Commander of the Big Mom Pirates and Linlin's son, known for his genie powers",
        "Caesar Clown": "The former scientist and captain of the Caesar Pirates, known for his gas powers and chemical weapons",
        "Bartholomew Kuma": "The former Warlord and Pacifista, known for his paw powers and mysterious transformation",
        "Morley": "The commander of the Revolutionary Army and giant, known for his freedom fighting and giant powers",
        "Page One": "The Headliner of the Beasts Pirates and Kaido's subordinate, known for his spinosaurus powers",
        "X Drake": "The captain of the Drake Pirates and SWORD agent, known for his allosaurus powers and undercover work",
        "Sai": "The leader of the Happo Navy and grandson of Chinjao, known for his haki mastery and alliance with Luffy"
    }
    
    # Mapeamento de tipos de estilo de luta
    fighting_types = {
        "swordsman": ["Gol D. Roger", "Shanks", "Dracule Mihawk", "Roronoa Zoro", "Izou", "Brook", "Charlotte Smoothie", "Charlotte Cracker", "Portgas D. Ace", "Who's-Who", "X Drake"],
        "devil_fruit": ["Edward Newgate", "Kaido", "Charlotte Linlin", "Marshall D. Teach", "Buggy", "Monkey D. Luffy", "Trafalgar D. Water Law", "Eustass Kid", "Loki", "Crocodile", "Boa Hancock", "King", "Marco", "Queen", "Charlotte Katakuri", "Vinsmoke Sanji", "Jack", "Nico Robin", "Charlotte Perospero", "Sabo", "Charlotte Snack", "Little Oars Jr.", "Chinjao", "Franky", "Pedro", "Scratchmen Apoo", "Capone Bege", "Donquixote Doflamingo", "Basil Hawkins", "Jewelry Bonney", "Gecko Moria", "Charlotte Oven", "Charlotte Daifuku", "Caesar Clown", "Bartholomew Kuma", "Page One"],
        "martial_arts": ["Jinbe", "Vinsmoke Sanji", "Charlotte Katakuri", "Pedro", "Chinjao", "Sai"],
        "technology": ["Franky", "Lindbergh"],
        "weather": ["Nami"],
        "revolutionary": ["Sabo", "Lindbergh", "Morley"],
        "giant": ["Loki", "Little Oars Jr.", "Morley"]
    }
    
    # Determinar tipo de estilo de luta
    fighting_type = "swordsman"  # padrão
    for ftype, names in fighting_types.items():
        if character["name"] in names:
            fighting_type = ftype
            break
    
    # Determinar nome do estilo
    style_names = {
        "swordsman": "Estilo de Uma Espada",
        "devil_fruit": "Estilo da Fruta do Diabo",
        "martial_arts": "Estilo de Artes Marciais",
        "technology": "Estilo Tecnológico",
        "weather": "Estilo do Clima",
        "revolutionary": "Estilo Revolucionário",
        "giant": "Estilo Gigante"
    }
    
    # Obter ataques e armas
    attacks = attacks_map.get(character["name"], ["Attack 1", "Attack 2", "Attack 3", "Attack 4"])
    weapons = weapons_map.get(character["name"], ["Weapon"])
    
    # Converter haki para o novo formato
    haki_mapping = {
        "Kenbunshoku Haki": "Kenbunshoku Haki (Haki da Observação)",
        "Busoshoku Haki": "Busoshoku Haki (Haki da Armadura)",
        "Haoshoku Haki": "Haoshoku Haki (Haki do Rei)"
    }
    
    new_haki = []
    for h in character.get("haki", []):
        new_haki.append(haki_mapping.get(h, h))
    
    # Remover símbolo de bounty
    bounty = character.get("bounty", "0")
    if isinstance(bounty, str) and bounty.startswith("฿"):
        bounty = bounty[1:]  # Remove o símbolo ฿
    elif isinstance(bounty, str) and "," in bounty:
        bounty = bounty.replace(",", "")
    
    # Criar novo objeto
    updated_character = {
        "id": character["id"],
        "name": character["name"],
        "nickname": character.get("nickname", ""),
        "age": character.get("age", 0),
        "race": "human",
        "signo": character.get("signo", "unknown"),
        "status": character.get("status", "unknown"),
        "occupation": character.get("occupation", []),
        "affiliations": character.get("affiliations", []),
        "bounty": bounty,
        "description": descriptions_map.get(character["name"], f"A powerful character known as {character.get('nickname', character['name'])}"),
        "image": character.get("image", ""),
        "crew": character.get("crew", None),
        "devilFruit": character.get("devil_fruit", None),
        "fightingStyle": {
            "name": style_names.get(fighting_type, "Estilo de Combate"),
            "type": fighting_type,
            "attacks": attacks[:4],  # Máximo 4 ataques
            "weapons": weapons
        },
        "haki": new_haki,
        "userId": "system",
        "createdAt": "2025-01-01T00:00:00-03:00",
        "updatedAt": "2025-01-01T00:00:00-03:00"
    }
    
    return updated_character

def update_bounties_file():
    """Atualiza o arquivo bounties.json completo"""
    
    # Ler o arquivo atual
    with open('assets/bounties.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Atualizar cada personagem
    updated_characters = []
    for character in data["characters"]:
        updated_character = update_character_format(character)
        updated_characters.append(updated_character)
    
    # Criar novo objeto de dados
    updated_data = {
        "total_count": data["total_count"],
        "characters": updated_characters
    }
    
    # Salvar o arquivo atualizado
    with open('assets/bounties.json', 'w', encoding='utf-8') as f:
        json.dump(updated_data, f, indent=2, ensure_ascii=False)
    
    print(f"Arquivo bounties.json atualizado com sucesso! {len(updated_characters)} personagens processados.")

if __name__ == "__main__":
    update_bounties_file() 