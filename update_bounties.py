#!/usr/bin/env python3
import json
import re

# Dados da API One Piece (fornecidos)
api_data = [
    {"id":1,"name":"Monkey D Luffy","size":"174cm","age":"19 ans","bounty":"3.000.000.000","crew":{"name":"The Chapeau de Paille crew"},"job":"Captain","status":"living"},
    {"id":2,"name":"Roronoa Zoro","size":"181cm","age":"21 ans","bounty":"320.000.000","crew":{"name":"The Chapeau de Paille crew"},"job":"Right-hand man","status":"living"},
    {"id":3,"name":"Nami","size":"170cm","age":"20 ans","bounty":"66.000.000","crew":{"name":"The Chapeau de Paille crew"},"job":"Navigator","status":"living"},
    {"id":4,"name":"Usopp","size":"176cm","age":"19 ans","bounty":"200.000.000","crew":{"name":"The Chapeau de Paille crew"},"job":"Sniper","status":"living"},
    {"id":5,"name":"Sanji","size":"180cm","age":"21 ans","bounty":"330.000.000","crew":{"name":"The Chapeau de Paille crew"},"job":"Cook","status":"living"},
    {"id":6,"name":"Tony-Tony Chopper","size":"90cm","age":"17 ans","bounty":"100","crew":{"name":"The Chapeau de Paille crew"},"job":"Doctor","status":"living"},
    {"id":7,"name":"Nico Robin","size":"188cm","age":"30 ans","bounty":"130.000.000","crew":{"name":"The Chapeau de Paille crew"},"job":"Archaeologist","status":"living"},
    {"id":8,"name":"Franky","size":"240cm","age":"36 ans","bounty":"94.000.000","crew":{"name":"The Chapeau de Paille crew"},"job":"Carpenter","status":"living"},
    {"id":9,"name":"Brook","size":"277cm","age":"90 ans","bounty":"83.000.000","crew":{"name":"The Chapeau de Paille crew"},"job":"Musician","status":"living"},
    {"id":10,"name":"Jinbe","size":"301cm","age":"46 ans","bounty":"438.000.000","crew":{"name":"The Chapeau de Paille crew"},"job":"Helmsman","status":"living"},
    
    # Adicionar mais personagens baseados na API
    {"name":"Edward Newgate","age":"72 ans","crew":{"name":"Whitebeard Pirates"},"status":"deceased"},
    {"name":"Gol D. Roger","age":"53 ans","crew":{"name":"Roger Pirates"},"status":"deceased"},
    {"name":"Kaido","age":"59 ans","crew":{"name":"Beasts Pirates"},"status":"living"},
    {"name":"Charlotte Linlin","age":"68 ans","crew":{"name":"Big Mom Pirates"},"status":"living"},
    {"name":"Shanks","age":"39 ans","crew":{"name":"Red Hair Pirates"},"status":"living"},
    {"name":"Marshall D. Teach","age":"40 ans","crew":{"name":"Blackbeard Pirates"},"status":"living"},
    {"name":"Dracule Mihawk","age":"43 ans","crew":{"name":"Cross Guild"},"status":"living"},
    {"name":"Buggy","age":"39 ans","crew":{"name":"Cross Guild"},"status":"living"},
    {"name":"Crocodile","age":"46 ans","crew":{"name":"Cross Guild"},"status":"living"},
    {"name":"Trafalgar D. Water Law","age":"26 ans","crew":{"name":"Heart Pirates"},"status":"living"},
    {"name":"Eustass Kid","age":"23 ans","crew":{"name":"Kid Pirates"},"status":"living"},
    {"name":"Boa Hancock","age":"31 ans","crew":{"name":"Kuja Pirates"},"status":"living"},
    {"name":"King","age":"47 ans","crew":{"name":"Beasts Pirates"},"status":"living"},
    {"name":"Marco","age":"45 ans","crew":{"name":"Whitebeard Pirates"},"status":"living"},
    {"name":"Queen","age":"56 ans","crew":{"name":"Beasts Pirates"},"status":"living"},
    {"name":"Charlotte Katakuri","age":"48 ans","crew":{"name":"Big Mom Pirates"},"status":"living"},
    {"name":"Jack","age":"28 ans","crew":{"name":"Beasts Pirates"},"status":"living"},
    {"name":"Charlotte Smoothie","age":"35 ans","crew":{"name":"Big Mom Pirates"},"status":"living"},
    {"name":"Charlotte Cracker","age":"45 ans","crew":{"name":"Big Mom Pirates"},"status":"living"},
    {"name":"Charlotte Perospero","age":"50 ans","crew":{"name":"Big Mom Pirates"},"status":"living"},
    {"name":"Sabo","age":"22 ans","crew":{"name":"Revolutionary Army"},"status":"living"},
    {"name":"Portgas D. Ace","age":"20 ans","crew":{"name":"Whitebeard Pirates"},"status":"deceased"},
    {"name":"Donquixote Doflamingo","age":"41 ans","crew":{"name":"Donquixote Pirates"},"status":"living"},
    {"name":"Gecko Moria","age":"50 ans","crew":{"name":"Thriller Bark Pirates"},"status":"living"},
    {"name":"Bartholomew Kuma","age":"47 ans","crew":{"name":"Revolutionary Army"},"status":"living"},
    {"name":"Scratchmen Apoo","age":"31 ans","crew":{"name":"On Air Pirates"},"status":"living"},
    {"name":"Capone Bege","age":"42 ans","crew":{"name":"Fire Tank Pirates"},"status":"living"},
    {"name":"Basil Hawkins","age":"31 ans","crew":{"name":"Hawkins Pirates"},"status":"living"},
    {"name":"Jewelry Bonney","age":"24 ans","crew":{"name":"Bonney Pirates"},"status":"living"},
    {"name":"X Drake","age":"33 ans","crew":{"name":"Drake Pirates"},"status":"living"},
]

# Mapeamento de nomes para padronizar
name_mapping = {
    "Monkey D. Luffy": "Monkey D Luffy",
    "Roronoa Zoro": "Roronoa Zoro", 
    "Nami": "Nami",
    "Usopp": "Usopp",
    "Vinsmoke Sanji": "Sanji",
    "Tony Tony Chopper": "Tony-Tony Chopper",
    "Nico Robin": "Nico Robin",
    "Franky": "Franky",
    "Brook": "Brook",
    "Jinbe": "Jinbe",
    "Edward Newgate": "Edward Newgate",
    "Gol D. Roger": "Gol D. Roger",
    "Kaido": "Kaido",
    "Charlotte Linlin": "Charlotte Linlin",
    "Shanks": "Shanks",
    "Marshall D. Teach": "Marshall D. Teach",
    "Dracule Mihawk": "Dracule Mihawk",
    "Buggy": "Buggy",
    "Crocodile": "Crocodile",
    "Trafalgar D. Water Law": "Trafalgar D. Water Law",
    "Eustass Kid": "Eustass Kid",
    "Boa Hancock": "Boa Hancock",
    "King": "King",
    "Marco": "Marco",
    "Queen": "Queen",
    "Charlotte Katakuri": "Charlotte Katakuri",
    "Jack": "Jack",
    "Charlotte Smoothie": "Charlotte Smoothie",
    "Charlotte Cracker": "Charlotte Cracker",
    "Charlotte Perospero": "Charlotte Perospero",
    "Sabo": "Sabo",
    "Portgas D. Ace": "Portgas D. Ace",
    "Donquixote Doflamingo": "Donquixote Doflamingo",
    "Gecko Moria": "Gecko Moria",
    "Bartholomew Kuma": "Bartholomew Kuma",
    "Scratchmen Apoo": "Scratchmen Apoo",
    "Capone Bege": "Capone Bege",
    "Basil Hawkins": "Basil Hawkins",
    "Jewelry Bonney": "Jewelry Bonney",
    "X Drake": "X Drake",
}

def normalize_name(name):
    """Normaliza nomes para matching"""
    # Remove prefixos como "Vinsmoke", "Tony Tony" etc
    name = re.sub(r'^(Vinsmoke|Tony Tony|Charlotte|Donquixote|Trafalgar D\. Water|Marshall D\.|Portgas D\.|Eustass)\s+', '', name)
    # Remove apelidos entre parênteses
    name = re.sub(r'\s*\([^)]*\)', '', name)
    return name.strip()

def extract_age_number(age_str):
    """Extrai número da idade"""
    if not age_str:
        return None
    match = re.search(r'(\d+)', age_str)
    return int(match.group(1)) if match else None

def map_crew_name(crew_name):
    """Mapeia nomes de crews da API para nomes mais limpos"""
    if not crew_name:
        return None
    
    crew_mapping = {
        "The Chapeau de Paille crew": "Straw Hat Pirates",
        "Blackbeard's crew": "Blackbeard Pirates",
        "Blackbeard Pirates": "Blackbeard Pirates",
        "Big Mom Pirates": "Big Mom Pirates",
        "Beasts Pirates": "Beasts Pirates",
        "Whitebeard Pirates": "Whitebeard Pirates",
        "Red Hair Pirates": "Red Hair Pirates",
        "Roger Pirates": "Roger Pirates",
        "Cross Guild": "Cross Guild",
        "Heart Pirates": "Heart Pirates",
        "Kid Pirates": "Kid Pirates",
        "Kuja Pirates": "Kuja Pirates",
        "Revolutionary Army": "Revolutionary Army",
        "Donquixote Pirates": "Donquixote Pirates",
        "Thriller Bark Pirates": "Thriller Bark Pirates",
        "On Air Pirates": "On Air Pirates",
        "Fire Tank Pirates": "Fire Tank Pirates",
        "Hawkins Pirates": "Hawkins Pirates",
        "Bonney Pirates": "Bonney Pirates",
        "Drake Pirates": "Drake Pirates",
    }
    
    return crew_mapping.get(crew_name, crew_name)

def update_bounties_with_api_data():
    """Atualiza o arquivo bounties.json com dados da API"""
    
    # Carregar bounties.json
    with open('assets/bounties.json', 'r', encoding='utf-8') as f:
        bounties_data = json.load(f)
    
    # Criar índice da API por nome normalizado
    api_index = {}
    for char in api_data:
        normalized_name = normalize_name(char['name'])
        api_index[normalized_name] = char
    
    # Atualizar personagens
    updated_count = 0
    for character in bounties_data['characters']:
        char_name = character['name']
        
        # Tentar encontrar match direto
        api_char = None
        
        # Tentar nome direto
        if char_name in name_mapping:
            api_name = name_mapping[char_name]
            api_char = api_index.get(normalize_name(api_name))
        
        # Tentar nome normalizado
        if not api_char:
            normalized = normalize_name(char_name)
            api_char = api_index.get(normalized)
        
        # Se encontrou match, adicionar os campos
        if api_char:
            # Adicionar crew
            if 'crew' in api_char and api_char['crew']:
                crew_name = map_crew_name(api_char['crew'].get('name'))
                if crew_name:
                    character['crew'] = crew_name
            
            # Adicionar status
            if 'status' in api_char and api_char['status']:
                status = api_char['status']
                # Normalizar status para inglês
                if status in ['vivant', 'living']:
                    character['status'] = 'living'
                elif status in ['mort', 'deceased']:
                    character['status'] = 'deceased'
                else:
                    character['status'] = status
            
            # Adicionar age
            if 'age' in api_char and api_char['age']:
                age_num = extract_age_number(api_char['age'])
                if age_num:
                    character['age'] = age_num
            
            updated_count += 1
            print(f"Updated: {char_name}")
        else:
            print(f"No match found for: {char_name}")
    
    # Salvar arquivo atualizado
    with open('assets/bounties.json', 'w', encoding='utf-8') as f:
        json.dump(bounties_data, f, indent=2, ensure_ascii=False)
    
    print(f"\nTotal characters updated: {updated_count}")
    print("bounties.json updated successfully!")

if __name__ == "__main__":
    update_bounties_with_api_data() 