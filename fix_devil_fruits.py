import json

def fix_devil_fruits():
    """Corrige todas as Akuma no Mi que estão nulas"""
    
    # Mapeamento de personagens e suas Akuma no Mi
    devil_fruits_map = {
        "Edward Newgate": "Gura Gura no Mi",
        "Kaido": "Uo Uo no Mi, Model: Seiryu",
        "Charlotte Linlin": "Soru Soru no Mi",
        "Marshall D. Teach": "Yami Yami no Mi",
        "Buggy": "Bara Bara no Mi",
        "Monkey D. Luffy": "Hito Hito no Mi, Model: Nika",
        "Trafalgar D. Water Law": "Ope Ope no Mi",
        "Eustass Kid": "Jiki Jiki no Mi",
        "Crocodile": "Suna Suna no Mi",
        "Boa Hancock": "Mero Mero no Mi",
        "King": "Ryu Ryu no Mi, Model: Pteranodon",
        "Marco": "Tori Tori no Mi, Model: Phoenix",
        "Queen": "Ryu Ryu no Mi, Model: Brachiosaurus",
        "Charlotte Katakuri": "Mochi Mochi no Mi",
        "Jack": "Zou Zou no Mi, Model: Mammoth",
        "Charlotte Smoothie": "Shibo Shibo no Mi",
        "Nico Robin": "Hana Hana no Mi",
        "Charlotte Cracker": "Bisu Bisu no Mi",
        "Charlotte Perospero": "Pero Pero no Mi",
        "Sabo": "Mera Mera no Mi",
        "Portgas D. Ace": "Mera Mera no Mi",
        "Who's-Who": "Neko Neko no Mi, Model: Saber Tiger",
        "Franky": None,  # Não tem Akuma no Mi
        "Brook": "Yomi Yomi no Mi",
        "Pedro": None,  # Não tem Akuma no Mi
        "Scratchmen Apoo": "Oto Oto no Mi",
        "Capone Bege": "Shiro Shiro no Mi",
        "Donquixote Doflamingo": "Ito Ito no Mi",
        "Basil Hawkins": "Wara Wara no Mi",
        "Jewelry Bonney": "Toshi Toshi no Mi",
        "Gecko Moria": "Kage Kage no Mi",
        "Charlotte Oven": "Netsu Netsu no Mi",
        "Charlotte Daifuku": "Hoya Hoya no Mi",
        "Caesar Clown": "Gasu Gasu no Mi",
        "Bartholomew Kuma": "Nikyu Nikyu no Mi",
        "Page One": "Ryu Ryu no Mi, Model: Spinosaurus",
        "X Drake": "Ryu Ryu no Mi, Model: Allosaurus"
    }
    
    # Ler o arquivo atual
    with open('assets/bounties.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Atualizar cada personagem
    updated_count = 0
    for character in data["characters"]:
        name = character["name"]
        if name in devil_fruits_map:
            devil_fruit = devil_fruits_map[name]
            if devil_fruit != character.get("devilFruit"):
                character["devilFruit"] = devil_fruit
                updated_count += 1
                print(f"Atualizado {name}: {devil_fruit}")
    
    # Salvar o arquivo atualizado
    with open('assets/bounties.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print(f"\nTotal de personagens atualizados: {updated_count}")
    print("Arquivo bounties.json atualizado com sucesso!")

if __name__ == "__main__":
    fix_devil_fruits() 