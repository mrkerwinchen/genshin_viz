#chooses colors for plot
gg_color_hue <- function(n) {
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}

#identify characters that match user query
pick_characters <- function(character_summary,
                            weapon_input, 
                            rarity_input, 
                            sex_input, 
                            type_input, 
                            nationality_input){
  character_summary %>%
    filter(weapon %in% weapon_input, 
           rarity %in% rarity_input,
           sex %in% sex_input,
           type %in% type_input,
           nation %in% nationality_input) %>% 
    pull(name)
}

#converts vector to human-readable list
coherent_vec<- function(vec){
  return(case_when(
    length(vec) == 1 ~ paste(vec[1]),
    length(vec) == 2 ~ paste(vec[1], "or", vec[2]),
    TRUE ~ paste(
      paste(vec[-length(vec)], collapse = ", "), 
      ", or ", 
      vec[length(vec)], 
      sep = "")
      )
  )
}

#generate subtitle for plot based on on user query
generate_subtitle <- function(weapon_input, 
                              rarity_input, 
                              sex_input, 
                              type_input, 
                              nationality_input){
  weapon <- case_when(
    length(weapon_input) == 0 ~ "no weapon",
    length(weapon_input) == 5 ~ "any weapon",
    TRUE ~ paste("", coherent_vec(weapon_input))
  )
  
  rarity <- case_when(
    length(rarity_input) == 0 ~ "No rarity",
    length(rarity_input) == 2 ~ "",
    TRUE ~ paste(
      rarity_input, 
      "-star",
      sep = "")
  )
  
  sex <- case_when(
    length(sex_input) == 0 ~ "sexless",
    length(sex_input) == 2 ~ "",
    TRUE ~ paste("", coherent_vec(sex_input))
  )

  type <- case_when(
    length(type_input) == 0 ~ "no type",
    length(type_input) == 7 ~ "any type",
    TRUE ~ paste("type", coherent_vec(type_input), sep = " ")
  )

  nationality <- case_when(
    length(nationality_input) == 0 ~ "nowhere",
    length(nationality_input) == 7 ~ "any nation",
    TRUE ~ paste("", coherent_vec(nationality_input))
  )
  
  return(
    paste(
      rarity,
      sex,
      "Character(s) of",
      type,
      "from",
      nationality,
      "that use",
      weapon
    )
  )
}


#plot data based on character query
genshin_plot <- function(queried_characters, data, title, subtitle){
  mutated_data <- mutate(data, 
                         Character = ifelse(variable %in% queried_characters,
                                            as.character(variable),
                                            "[Other]")) 
  ggplot() +
    geom_line(data = mutated_data[mutated_data$Character == "[Other]",],
              aes(x = Level, 
                  y = ATK, 
                  group = variable, 
                  color = Character)) +
    geom_line(data = mutated_data[mutated_data$Character != "[Other]",],
              aes(x = Level, 
                  y = ATK, 
                  group = variable, 
                  color = variable, 
                  size = Character), 
              show.legend = F) +
    scale_color_manual(values = c("lightgrey", 
                                  gg_color_hue(length(queried_characters)))) +
    scale_size_manual(values=rep(1., length(queried_characters))) +
    labs(title=title, 
         subtitle=str_wrap(subtitle, 100), 
         y="Value") 
}


