# title:   Snake Game
# author:  Guilherme Alvarenga, Joao P., Maria Eduarda, Michael Todoroki, Pedro Freitas
# desc:    LP - Grupo Skane Game (Ruby)
# version: 0.3
# script:  ruby

# Variáveis globais para o menu
$menu = true # Define se o jogo está no menu ou não
$food_count = 1 # Número inicial de comidas
$option_category = 0 # Categoria de opções
$option_index_fruits = 0 # Índice da opção de frutas
$option_index_size = 0 # Índice da opção de tamanho
$menu_cooldown = 0  # Controla a sensibilidade da navegação
$velocidade = 1 # Guarda o valor da velocidade do jogo para mostrar ao jogador
$comecou = false # Define se o jogo já começou

# Constantes globais para dimensões da malha
$grid_width  = 28
$grid_height = 15
$cell_size = 8

# Função para inicializar o jogo
def init
  $cell_size = [240 / $grid_width, 136 / $grid_height].min

  srand(Time.now.to_i) 

  $score = 0
  $snake = calcula_posicao_inicial_cobra
  $direction = [1, 0]
  $next_direction = [1, 0]
  $foods = []
  initial_food_positions = posicao_inicial_foods($food_count)

  initial_food_positions.each do |pos|
    unless $snake.include?(pos) || $foods.include?(pos)
      $foods << pos
    end
  end

  # Verifica se todas as frutas foram posicionadas, senão gera novas posições
  while $foods.size < $food_count
    new_food = [rand($grid_width ), rand($grid_height)]
    $foods << new_food unless $snake.include?(new_food) || $foods.include?(new_food)
  end

  $game_over = false
  $game_win = false
  $frame_counter = 0 
  $speed_factor = 10 
  $last_speed_update = 0
end

def calcula_posicao_inicial_cobra
  # Centraliza a cobra na grade
  x = $grid_width / 2
  y = $grid_height / 2
  [[x - 3, y]] # Cobra começa com um único segmento na posição central
end

def posicao_inicial_foods(food_count)
  vetor = []
  x_base = $grid_width / 2  # Começa no meio da grade (horizontal)
  y_base = $grid_height / 2 # Começa no meio da grade (vertical)

  offsets = [
    [0, 0], [-1, 0], [1, 0], [0, -1], [0, 1],  # Centro + arredores
    [-1, -1], [-1, 1], [1, -1], [1, 1]         # Diagonais
  ]

  count = 0
  offset_index = 0

  while count < food_count && offset_index < offsets.size
    dx, dy = offsets[offset_index]
    x = x_base + dx
    y = y_base + dy

    # Garante que a posição está dentro dos limites da grade
    if x.between?(0, $grid_width - 1) && y.between?(0, $grid_height - 1)
      vetor << [x, y]
      count += 1
    end

    offset_index += 1
  end

  vetor
end


# No início, defina o botão com valores iniciais adequados
$botao_confirmar = { x: 160, y: 130, w: 65, h: 200, texto: "APERTE ENTER" }

def menu_update
  # Reduz o cooldown a cada frame
  $menu_cooldown = [$menu_cooldown - 1, 0].max

  # Navegação com botões UP (0) e DOWN (1)
  if $menu_cooldown <= 0
    if btn(0)  # Botão UP
      if $option_category == 0
        $option_index_fruits = ($option_index_fruits - 1) % 4
      elsif $option_category == 1
        $option_index_size = ($option_index_size - 1) % 4
      end
      $menu_cooldown = 10
    elsif btn(1)  # Botão DOWN
      if $option_category == 0
        $option_index_fruits = ($option_index_fruits + 1) % 4
      elsif $option_category == 1
        $option_index_size = ($option_index_size + 1) % 4
      end
      $menu_cooldown = 10
    end
  end

  # Navegação com as setas esquerda (2) e direita (3)
  if $menu_cooldown <= 0
    if btn(2)  # Botão LEFT
      $option_category = ($option_category - 1) % 2
      $menu_cooldown = 10
    elsif btn(3)  # Botão RIGHT
      $option_category = ($option_category + 1) % 2
      $menu_cooldown = 10
    end
  end

  # Verifica se a tecla Enter foi pressionada
  if keyp(50) || btnp(4)  # Enter ou botão 4
    case $option_index_fruits
    when 0 then $food_count = 1
    when 1 then $food_count = 3
    when 2 then $food_count = 5
    when 3
      $food_count = 1 + rand(9)
    end
    
    srand(Time.now.to_i) 
    while $option_index_size == 3
        $option_index_size = rand(4) # Gera o número aleatório
    end 

    case $option_index_size
    when 0
      $grid_width = 7
      $grid_height = 3
    when 1
      $grid_width = 14
      $grid_height = 7
    when 2
      $grid_width = 28
      $grid_height = 15
    end

    $menu = false
    init
  end
end

def menu_draw
  cls(0) # Limpa a tela 

  screen_width = 240
  screen_height = 120

  # Variável para controlar a animação de mudança de cor do título
  $t ||= 0  # Inicializa $t se ainda não estiver definido

  # Animação para mudança de cores do título
  color = 11  # Cor inicial (azul claro)
  if $t % 60 < 30
      color = 15  # Muda para branco, cria um efeito piscante
  end

  # Título do jogo com escala ampliada e centralizado
  title = "SNAKE GAME"
  scale = 2
  title_width = title.length * 6 * scale  # Calcula a largura do título com a escala
  x_title = (screen_width - title_width) / 2  # Centraliza o título horizontalmente
  y_title = 15  # Posição vertical para o título
  print(title, x_title, y_title, color, false, scale)  # Imprime o título com escala e cor dinâmica

  # Exibir a opção escolhida para quantidade de frutas
  fruits_text = case $option_index_fruits
                when 0 then "FRUTAS: 1"
                when 1 then "FRUTAS: 3"
                when 2 then "FRUTAS: 5"
                when 3 then "FRUTAS: ?"
                end
  print(fruits_text, 50, 30, 15)  # Mostra o texto na tela

  # Exibir a opção escolhida para tamanho da malha
  size_text = case $option_index_size
              when 0 then "TAMANHO: PEQUENA"
              when 1 then "TAMANHO: MEDIA"
              when 2 then "TAMANHO: GRANDE"
              when 3 then "TAMANHO: ?"
              end
  print(size_text, 127, 30, 15)  # Mostra o texto na tela

  # Definição das opções de frutas 
  options_fruits = [1, 3, 5, "Aleatório"]
  start_y_fruits = 45
  option_gap = 20 # Espaçamento entre as opções
  sprite_spacing = 10  # Aumenta o espaçamento para melhor visualização

  options_fruits.each_with_index do |opt, index| 
    y = start_y_fruits + index * option_gap 

    # Destacar a opção selecionada com setas
    if index == $option_index_fruits && $option_category == 0
      print(">", 35, y, 15)  # Seta para a esquerda
      print("<", 100, y, 15)  # Seta para a direita
    end

    # Desenha sprites conforme a opção
    if opt.is_a?(Integer)
      count = opt
      total_width = count * sprite_spacing
      start_x = - 50 + (screen_width - total_width) / 2  # Centraliza os sprites horizontalmente
      count.times do |i|
        spr(70, start_x + i * sprite_spacing, y, 6)  # Sprite de comida
      end
    else
      # Opção "Aleatório": sprite de comida + ponto de interrogação
      base_x = - 50 + (screen_width - sprite_spacing) / 2 
      spr(70, base_x, y, 6)  # Sprite de comida
      print("?", base_x + 2, y + 2, 0)  # Ponto de interrogação
    end
  end

  # Definição das opções de tamanho
  options_size = ["Pequeno", "Médio", "Grande", "Aleatório"]
  total_options = options_size.size
  start_y = 45  # Posição inicial no eixo Y
  menu_height = 136  # Altura total do menu
  remaining_height = menu_height - start_y
  # Calcular a altura total das malhas manualmente
  total_malha_height = 0
  options_size.each do |opt|
    height = opt == "Pequeno" ? 2 : opt == "Médio" ? 3 : opt == "Grande" ? 4 : 3
    total_malha_height += height * 4  # Multiplica pelo tamanho das células
  end
  gap = ((remaining_height - total_malha_height) / (total_options - 1) ) - 6

  current_y = start_y

  options_size.each_with_index do |opt, index|
    width = opt == "Pequeno" ? 4 : opt == "Médio" ? 6 : opt == "Grande" ? 8 : 3
    height = opt == "Pequeno" ? 2 : opt == "Médio" ? 3 : opt == "Grande" ? 4 : 3

    # Calcular a posição `y` considerando o topo de cada malha
    y = current_y

    # Destacar a opção selecionada com setas
    if index == $option_index_size && $option_category == 1
      print(">", 125, y, 15)  # Seta para a esquerda
      print("<", 200, y, 15)  # Seta para a direita
    end

    # Desenhar malha proporcional
    cell_size = 4  # Tamanho das células no menu
    offset_x_size = 160 - (width * cell_size) / 2  # Centralizar horizontalmente

    (0...width).each do |x|
      (0...height).each do |grid_y|  # Renomeado para evitar conflito com a variável `y`
        spr((x + grid_y) % 2 == 0 ? 34 : 35, offset_x_size + x * cell_size, y + grid_y * cell_size, -1)
      end
    end

    # Adicionar ponto de interrogação se for "Aleatório"
    if opt == "Aleatório"
      print("?", offset_x_size + (width * cell_size) / 2 - 2, y + (height * cell_size) / 2 - 3, 0)
    end

    # Atualizar `current_y` para a próxima malha
    current_y += height * 4 + gap
  end

  # Configurar e desenhar o botão de confirmação
  button_width = 85 # Largura do botão
  button_height = 200 # Altura do botão
  button_x = (screen_width - button_width) / 2 # Posição X do botão
  button_y = 40 + 4 * option_gap + 5 # Posição Y do botão

  # Atualiza as coordenadas do botão
  $botao_confirmar[:x] = button_x
  $botao_confirmar[:y] = button_y
  $botao_confirmar[:w] = button_width
  $botao_confirmar[:h] = button_height

  # Desenhar o botão de confirmação
  desenha_botao($botao_confirmar)

  $t = ($t + 1) % 360  # Incrementa o contador de tempo para animação  
end

def desenha_botao(botao)
  # Desenha o retângulo do botão com uma cor de destaque
  rect(botao[:x], botao[:y], botao[:w], botao[:h], 12)  # Cor 12 pode ser azul ou outra de destaque
  # Desenha o texto do botão centralizado
  print(botao[:texto], botao[:x] + ((botao[:w] / 2) - 8) - (botao[:texto].length * 2), botao[:y] + 3, 15) # Texto na cor 15 (branco)
end

def update
  if $game_over || $game_win  
    music()
    # Verifica se qualquer tecla ou botão foi pressionado para reiniciar
    if keyp(50) || btnp(4)
      $menu = true
      $game_over = false
      $game_win = false
      $game_started = false
      init
    end
    return  # Sai do método após reiniciar
  end

  unless $game_started
    # Verifica se o jogo deve iniciar
    if btnp(0) || btnp(1) || btnp(2) || btnp(3) || keyp(50) || btnp(4)  
      $game_started = true
    end
    return unless $game_started  # Não continua se o jogo ainda não começou
  end

  # Lógica normal do jogo
  adjust_speed

  if btn(0)
    $next_direction = [0, -1] if $direction != [0, 1]
  elsif btn(1)
    $next_direction = [0, 1] if $direction != [0, -1]
  elsif btn(2)
    $next_direction = [-1, 0] if $direction != [1, 0]
  elsif btn(3)
    $next_direction = [1, 0] if $direction != [-1, 0]
  end

  $frame_counter += 1

  if $frame_counter % $speed_factor == 0
    $direction = $next_direction
    move_snake
  end
end

def adjust_speed
  # Garante que $last_speed_update e $score são números
  $last_speed_update ||= 0
  $score ||= 0

  # Reduz o speed_factor quando o score ultrapassa múltiplos de 20, até um mínimo de 4
  if $score >= $last_speed_update + 15
    $velocidade += 1
    $speed_factor = [4, $speed_factor - 1].max
    $last_speed_update += 15
  end
end

def move_snake
  head = [$snake[0][0] + $direction[0], $snake[0][1] + $direction[1]]
  
  # Verifica se a cabeça da cobra ultrapassou as bordas da malha
  if head[0] < 0 || head[0] >= $grid_width  || head[1] < 0 || head[1] >= $grid_height
    $game_over = true
    music()
    $comecou = false
    sfx(4, 25)
    return  # Para a execução da função se a cobra atingir as bordas
  end

  if $foods.include?(head)
    sfx(1, 38)
    $snake.unshift(head)
    $foods.delete(head)  # Remove a maçã comida
    $score += 1      # Incrementa o score em 1 ponto

    # Gera um novo alimento para substituir o que foi comido
    new_food = nil
    loop do
      new_food = [rand($grid_width ), rand($grid_height)]
      break unless $snake.include?(new_food) || $foods.include?(new_food)
    end
    $foods << new_food
  else
    $snake.pop
    $snake.unshift(head)
  end

  check_collision
  check_win
end


def check_collision
  head = $snake[0]
  if $snake[1..-1].include?(head)
    $game_over = true
    music()
    $comecou = false
    sfx(4, 25)
  end
end

def check_win
  if $score == $grid_width  * $grid_height - $food_count - 2
    $game_win = true
    music()
    $comecou = false
    sfx(4, 56)
  end
end

def direction_change(segment)
  index = $snake.index(segment)
  return nil if index == 0 || index == $snake.length - 1

  prev_segment = $snake[index - 1]
  next_segment = $snake[index + 1]

  prev_direction = [segment[0] - prev_segment[0], segment[1] - prev_segment[1]]
  next_direction = [next_segment[0] - segment[0], next_segment[1] - segment[1]]

  [prev_direction, next_direction]
end

def draw
  cls(0)

  screen_width = 240
  screen_height = 136

  $cell_size = 8

  # Calcula dimensões da malha
  element_width = $grid_width * $cell_size
  element_height = $grid_height * $cell_size

  # Calcula os offsets para centralizar
  offset_x = (screen_width - element_width) / 2
  offset_y = (screen_height - element_height) / 2

  # Desenhar a malha
  (0...$grid_width).each do |x|
    (0...$grid_height).each do |y|
      spr((x + y) % 2 == 0 ? 69 : 75, offset_x + x * $cell_size, offset_y + y * $cell_size, -1)
    end
  end

  if $snake.length == 1
    $snake.unshift([$snake[0][0] + $direction[0], $snake[0][1] + $direction[1]])
  end

  # Determina o sprite para a cabeça baseado na direção atual
  head_sprite = case $direction
  when [1, 0]  # Direita
    65
  when [-1, 0] # Esquerda
    67
  when [0, -1] # Cima
    66
  when [0, 1]  # Baixo
    68
  else 
    65
  end
  
  # Desenha a cabeça da cobra com o offset aplicado
  spr(head_sprite, offset_x + $snake[0][0] * $cell_size, offset_y + $snake[0][1] * $cell_size, 6)
  
  # Determina o sprite para a cauda baseado na direção entre os dois últimos segmentos
  if $snake.length > 1
    tail_sprite = case [$snake[-2][0] - $snake[-1][0], $snake[-2][1] - $snake[-1][1]]
    when [1, 0]  # Direita
      71  
    when [-1, 0] # Esquerda
      73  
    when [0, -1] # Cima
      74   
    when [0, 1]  # Baixo
      72  
    else
      64
    end

    # Desenha a cauda da cobra com o offset aplicado
    spr(tail_sprite, offset_x + $snake[-1][0] * $cell_size, offset_y + $snake[-1][1] * $cell_size, 6)
  end

  # Pinta o corpo da cobra
  if $snake.length > 1
    $snake[1..-2].each do |segment|
      directions = direction_change(segment)
      prev_direction, next_direction = directions
      body = 64  # Valor padrão para o corpo

      if prev_direction == [1, 0] && next_direction == [0, 1] || prev_direction == [0, 1] && next_direction == [1, 0]
        body = prev_direction == [1, 0] ? 79 : 77
      elsif prev_direction == [1, 0] && next_direction == [0, -1] || prev_direction == [0, -1] && next_direction == [1, 0]
        body = prev_direction == [1, 0] ? 63 : 78
      elsif prev_direction == [-1, 0] && next_direction == [0, 1] || prev_direction == [0, 1] && next_direction == [-1, 0]
        body = prev_direction == [-1, 0] ? 78 : 63
      elsif prev_direction == [-1, 0] && next_direction == [0, -1] || prev_direction == [0, -1] && next_direction == [-1, 0]
        body = prev_direction == [-1, 0] ? 77 : 79
      else
        body = case [$snake[$snake.index(segment) - 1][0] - segment[0], $snake[$snake.index(segment) - 1][1] - segment[1]]
        when [1, 0], [-1, 0]  # Horizontal
          64
        when [0, -1], [0, 1]  # Vertical
          76
        else
          64
        end
      end

      spr(body, offset_x + segment[0] * $cell_size, offset_y + segment[1] * $cell_size, 6)
    end
  end

  tail = $snake[-1]
  spr(tail_sprite, offset_x + tail[0] * $cell_size, offset_y + tail[1] * $cell_size, 6)

  head = $snake[0]
  spr(head_sprite, offset_x + head[0] * $cell_size, offset_y + head[1] * $cell_size, 6)

  $foods.each do |food|
    spr(70, offset_x + food[0] * $cell_size, offset_y + food[1] * $cell_size, 6)
  end

  rect_border_x = offset_x - 1
  rect_border_y = offset_y - 1
  rect_border_width = $grid_width  * $cell_size + 2  # Largura da malha mais 2 pixels para borda
  rect_border_height = $grid_height * $cell_size + 2  # Altura da malha mais 2 pixels para borda
  rectb(rect_border_x, rect_border_y, rect_border_width, rect_border_height, 12)  # Cor 15 é branco no TIC-80

  if $game_over || $game_win
    $t ||= 0  # Inicializa $t se ainda não estiver definido

    # Título de "Game Over" ou "Parabéns"
    title = $game_over ? "GAME OVER" : "PARABENS!"
    color = $t % 60 < 30 ? 15 : 11  # Animação de cor piscante
    scale = 2
    x_title = (240 - title.length * 6 * scale) / 2
    y_title = 30
    print(title, x_title, y_title, color, false, scale)
    
    # Botão "Reiniciar"
    button_text = "REINICIAR"
    button_width = button_text.length * 6 + 6
    button_height = 12
    button_x = (240 - button_width) / 2
    button_y = y_title + 80

    # Desenhar o botão
    rect(button_x, button_y, button_width, button_height, 12)  # Fundo azul
    print(button_text, button_x + 5, button_y + 4, 15)  # Texto branco

    # Armazena as dimensões do botão para interação
    $restart_button = { x: button_x, y: button_y, w: button_width, h: button_height }
    
    $t = ($t + 1) % 360
  end
  
  # Exibe o score
  print("SCORE: #{$score}", 8, 0, 12)
  # Exibe a velocidade atual
  print("VELOCIDADE: #{$velocidade}x", 162, 0, 12) 
end

def TIC
  if $menu
    menu_update
    music(0, 0, 0, true) if $comecou
    $comecou = false unless !$comecou
    menu_draw
  else
    update
    music(1, 0, 0, true) if !$comecou
    $comecou = true unless $comecou
    draw
  end
end

music(0, 0, 0, true)