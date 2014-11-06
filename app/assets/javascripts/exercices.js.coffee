# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
######################################################################     
# Variable globale membre=valeur d'un membre, solution=$? (l'inconnue) 
debug = false
[membre, solution] = [0,0]  

######################################################################  
# Fonction permettant d'inserer un #exo_id dans #enonce
######################################################################  
choisir_exo = (input, output) ->
  exo = $( input )
  [membre, solution] = [exo.data( "membre" ), exo.data( "solution" )]  
  # On parse le texte a la recherche des $ et des # qui symbolisent les items de chacun des membres de l'équation
  text = exo
    .text()
    .replace(/@\[([ 0-9a-zA-Z]*),([0-9a-zA-Z]*),([0-9a-zA-Z?€]*),([0-9a-zA-Z]*),([0-9a-zA-Z]*),([0-9a-zA-Z]*)\]/g , "<div class='element $1 $6' data-type='$2' data-affichage='$3' data-couleur='$4' data-valeur='$5'>$3</div>" )

  # Prise en charge de la rotation du panel pour la boite de dialogue
  if $( "#panel" ).hasClass( "rotate")
    [width, height] = [$(window).width(), $(window).height() * 0.3]  
  else
    [width, height] = [$(window).width() * .3, $(window).height()]  
  # On Fabrique un énoncé avec des elements (uniques) de chaque membre de l'équation draggables
  $( ".element" ).remove()
  $( "#{output}" ).empty().append("<div class='enonce'>#{text}</div>").dialog
    width: width
    height: height
    position:
      my: "right bottom"
      at: "right bottom"
      of: "#panel"
  # Les cartes de l'enoncé sont draggable et deviendront des dropped
  $( ".element" )
    .css
      background: -> $( this ).data( "couleur" )
    .draggable
      revert: "invalid"
      helper: "clone"
      appendTo: "#panel"
######################################################################  
checkpanel = () ->
###################################################################### 
  # Sommer les cartes d'un certains type d'un certain panel
  ######################################################################  
  somme = ( panel, classe) ->
    selector = "#{panel} > #{classe}"
    s = 0
    $( selector ).each ->
      s += $( this ).data( "valeur" )
    return s
  # Quel est le type de la premiere carte du panel en haut
  gauche_en_haut = $( '#panel_top div:first-child' ).hasClass("gauche")
  if gauche_en_haut
    t = somme("#panel_top", ".gauche")
    b = somme("#panel_bottom", ".droite")
  # Du coup cela définit un peu tout le reste !  
  else
    t = somme("#panel_top", ".droite")
    b = somme("#panel_bottom", ".gauche")
  # Roulement de tambour, si tout n'est pas mélangé que les sommes sont exactes qu'il n'y a pas de carte piège alors c'est bon!  
  succes = t is b and b is parseInt(membre) and $( ".piege.dropped" ).length is 0
  if succes
    alert "bravo !"
  else
    alert "Essayes encore !" 
  alert "top:#{t} & bottom:#{b} doivent etre egal a membre:#{parseInt(membre)} car condition:#{succes}" if debug
       

 
######################################################################     
# On Dom Ready !   
######################################################################  
$ ->
######################################################################    
# Menu #paramètres
######################################################################  
######################################################################  
  #Menu select
  ######################################################################  
  $( ".exercice" ).each ->
    id = $( this ).attr("id")
    html = "<option value='#{id}'>#{id}</option>"
    $( "#exercices" ).append(html)
  $( "#exercices" ).selectmenu
    select: ( event, data ) -> choisir_exo( "##{data.item.value}", "#enonce" )  
  $( "#select_opener" ).click () -> $( "#exercices" ).selectmenu( "open" )
  $( "#parametres" ).dialog
    autoOpen: false
  $( "#menu_parametres" ).click () -> 
    if $( " #parametres" ).dialog( "isOpen" ) 
      $( "#parametres" ).dialog( "close" )
    else
      $( "#parametres" ).dialog( "open" )
    # Checkbox #paramètres
    ######################################################################  
  $(' #checkbox_aide ').change () -> 
    if $(this).is(":checked")
      $( ".dropped" ).addClass( "aide" )
    else
      $( ".dropped" ).removeClass( "aide" )
  $(' #checkbox_piege ').change () -> 
    if $(this).is(":checked")
      $( ".piege" ).addClass( "element" ).draggable('enable')
    else
      $( ".piege.dropped" ).remove()
      $( ".piege" ).draggable('disable').removeClass( "element" )
  $(' #checkbox_rotate ').change () -> 
    if $(this).is(":checked")
      $( "#panel, #panel_top, #panel_bottom" ).addClass( "rotate" )
    else
      $( "#panel, #panel_top, #panel_bottom" ).removeClass( "rotate" )
  
    # Corbeille droppable
    ######################################################################  
  $('#trash').droppable
    accept: ".dropped" 
    greedy: true
    activeClass: "trash-active"
    hoverClass: "trash-hover"
    drop: (event,ui) -> 
      event.stopPropagation()
      ui.draggable.remove()
    over: (event,ui) -> ui.draggable.addClass( "remove" ).removeClass( "element")
    out: (event,ui) ->  ui.draggable.addClass( "element" ).removeClass( "remove")
    
  ######################################################################  
  ######################################################################  
  # Panels droppable  
  ######################################################################  
  $('#panel_top, #panel_bottom').droppable
    accept: ".element" 
    activeClass: "panel-active"
    hoverClass: "panel-hover"
    drop: (event,ui) ->   
      #Fonction pour ajuster le drop d'une carte dans le panel
      ######################################################################  
      positionneBien = ( unDraggable ) => 
        $( this ).append unDraggable
        if not unDraggable.hasClass( "dropped" )
          unDraggable.css
            left: event.clientX - unDraggable.width() /2 - $( this ).position().left
            top : event.clientY  - unDraggable.height() /2
        else
          unDraggable.css
            left: event.clientX - unDraggable.width()/2 - $( this ).position().left
            top : event.clientY  - unDraggable.height() / 2 
      ######################################################################  
      if ui.draggable.hasClass( "dropped" )   
        positionneBien $( ui.draggable )
      else
        leClone = ui.draggable.clone() 
        positionneBien leClone
        if $( "#checkbox_aide" ).is(":checked")
          $( leClone ).addClass("aide")          
        # La dropped crée doit devenir draggable  
        $( leClone ).addClass( "dropped" ).draggable
          revert: "invalid"
          cursor: "move" 
######################################################################  
# Vérifier sa modélisation 
###################################################################### 
######################################################################   
  $('#check').click () -> checkpanel()
  
  
    