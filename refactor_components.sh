#!/bin/bash

# A Estrela Guia: Diretório alvo onde os componentes vivem.
TARGET_DIR="src/components"

echo "=== INICIANDO REATORAÇÃO DE COMPONENTES (v2 - Ciente do <script setup>) ==="
echo "AVISO: Esta é uma operação destrutiva. Tenha certeza de que seu código está commitado."
read -p "Pressione [Enter] para continuar ou [Ctrl+C] para cancelar."

find "$TARGET_DIR" -type f -name "*.vue" | while read vue_file; do
    
    dir_path=$(dirname "$vue_file")
    file_name=$(basename "$vue_file")
    base_name="${file_name%.vue}"
    sub_dir="$dir_path/$base_name"

    echo "-----------------------------------------------------"
    echo "Processando: $vue_file"

    if [ -d "$sub_dir" ]; then
        echo "Pasta '$sub_dir' já existe. Pulando."
        continue
    fi

    mkdir -p "$sub_dir"
    echo "  -> Criada pasta: $sub_dir"

    # --- Extração do <template> ---
    template_content=$(sed -n '/<template>/,/<\/template>/p' "$vue_file" | sed '1d;$d')
    if [ -n "$template_content" ]; then
        echo "$template_content" > "$sub_dir/$base_name.html"
        echo "  -> Extraído: $base_name.html"
    fi

    # --- Extração do <style> ---
    style_tag=$(grep '<style' "$vue_file")
    style_content=$(sed -n '/<style.*>/,/<\/style>/p' "$vue_file" | sed '1d;$d')
    style_scoped=""
    if [[ $style_tag == *"scoped"* ]]; then
        style_scoped="scoped"
    fi

    if [ -n "$style_content" ]; then
        echo "$style_content" > "$sub_dir/$base_name.css"
        echo "  -> Extraído: $base_name.css"
    fi
    
    # --- VERIFICAÇÃO E EXTRAÇÃO CONDICIONAL DO <script> ---
    script_tag=$(grep '<script' "$vue_file")
    original_script_block="" # Variável para guardar o script setup original
    
    # SE for <script setup>, NÃO extraímos. Guardamos o bloco inteiro.
    if [[ $script_tag == *'setup'* ]]; then
        echo "  -> <script setup> detectado. Mantendo no .vue."
        original_script_block=$(sed -n '/<script.*>/,/<\/script>/p' "$vue_file")
    else
        # Se for um script normal, extrai como antes. (Lógica mantida para flexibilidade)
        script_content=$(sed -n '/<script.*>/,/<\/script>/p' "$vue_file" | sed '1d;$d')
        script_ext="js"
        if [[ $script_tag == *"lang=\"ts\""* ]]; then
            script_ext="ts"
        fi
        if [ -n "$script_content" ]; then
            echo "$script_content" > "$sub_dir/$base_name.$script_ext"
            echo "  -> Extraído: $base_name.$script_ext"
        fi
    fi

    # --- Reescreve o arquivo .vue original ---
    
    # Primeiro, apaga o conteúdo antigo
    > "$vue_file"

    # Se havia um <script setup>, ele é a primeira coisa a ser escrita de volta.
    if [ -n "$original_script_block" ]; then
        echo "$original_script_block" >> "$vue_file"
        echo "" >> "$vue_file" # Adiciona uma linha em branco para separação
    fi

    # Agora, adiciona as tags de importação para template e style
    echo "<template src=\"./$base_name/$base_name.html\"></template>" >> "$vue_file"

    if [ -n "$style_content" ]; then
        echo "<style $style_scoped src=\"./$base_name/$base_name.css\"></style>" >> "$vue_file"
    fi

    echo "  -> Reescrevido: $file_name"

done

echo "-----------------------------------------------------"
echo "=== REATORAÇÃO CONCLUÍDA ==="
echo "Verifique as mudanças com 'git diff' e teste a aplicação."