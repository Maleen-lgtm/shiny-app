library(shiny)
library(leaflet)

# Stationen mit Symbolen statt Bildern
stationen <- data.frame(
  name = c(
    "Startpunkt: Zuhause",
    "Schloss Rosenborg",
    "Runder Turm",
    "Strøget",
    "Nyhavn",
    "Amalienborg",
    "Kleine Meerjungfrau"
  ),
  ort_info = c(
    "Hier beginnt unser kleines Abenteuer – Es ist zwar nicht unser Zuhause, aber unser süßes kleines Airbnb, bzw. in der Nähe davon, weil ich Google nicht unseren direkten 
    Aufenthaltsort mitteilen wollte. Denn letztendlich kommt es nicht darauf an, wo unser Zuhause ist, sondern wo wir uns wie Zuhause fühlen. Und wir fühlen uns bei dir Zuhause 💛",
    "Rosenborg ist ein märchenhaftes Schloss mit einem wunderschönen Park – mitten in der Stadt.",
    "Der Runde Turm ist berühmt für seine spiralförmige Rampe und den Blick über ganz Kopenhagen.",
    "Strøget ist eine der längsten Einkaufsstraßen Europas – voller Leben, Menschen und Geschichten.",
    "Nyhavn ist ein farbenfroher Hafen voller Geschichte und gemütlicher Atmosphäre – ein echtes Wahrzeichen.",
    "Amalienborg ist der Wohnsitz der dänischen Königsfamilie – elegant, ruhig und würdevoll.",
    "Die kleine Meerjungfrau erinnert an die Märchenwelt von H.C. Andersen und ist ein Symbol für Sehnsucht und Liebe."
  ),
  mama_liebe = c(
    "Ein Zuhause kann so vieles bedeuten und sein. Danke, dass du uns immer ein Zuhause gibst – egal wo wir sind, mit dir fühlt sich alles an wie Zuhause.",
    "Mama, du hast so viel Klasse und Herzlichkeit – wie ein Schloss voller schöner Erinnerungen. Du sammelst nicht nur Erfahrungen für dich alleine, sondern 
    teilst sie mit uns und lässt uns an all den schönen Dingen in deinem Leben teilhaben.",
    "Mit dir sehen wir die Welt von oben – du gibst uns Weitblick und Vertrauen. Dafür danken wir dir sehr.",
    "Mit dir macht selbst ein Spaziergang durch eine Einkaufsstraße Spaß. Danke für deine Energie.",
    "Wie Nyhavn bringst du Farbe und Wärme in unser Leben. Wir lieben nicht durch deine Shoppinglust, sondern auch deine Herzlichkeit.",
    "Du bist für uns wie eine Mama-Königin – stark, würdevoll, und doch ganz nahbar. Und dabei bist du stets beschützend und weichst und niemals von der Seite.",
    "Du bist für uns wie ein Fels in der Brandung. Du strahlst Ruhe aus und zeigst uns was bedingungslose Liebe bedeutet – genau wie die kleine Meerjungfrau hier vor dir."
  ),
  symbol = c("🏡", "🏰", "🔭", "🛍️", "⚓", "👑", "🧜‍♀️"),
  lat = c(55.7130, 55.6866, 55.6833, 55.6783, 55.6805, 55.6847, 55.6929),
  lng = c(12.5782, 12.5776, 12.5760, 12.5754, 12.5886, 12.5931, 12.5990),
  stringsAsFactors = FALSE
)

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {
        background-color: #f9f6f2;
        font-family: 'Georgia', serif;
        color: #444;
        margin: 0;
        padding: 0;
      }
      h2 {
        color: #a52a2a;
        margin-top: 20px;
        text-align: center;
        font-size: 2rem;
      }
      .inhaltbox {
        max-width: 700px;
        margin: auto;
        background-color: #fffaf5;
        padding: 30px 20px;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        text-align: center;
      }
      blockquote {
        font-style: italic;
        color: #a52a2a;
        border-left: 5px solid #e6d1c4;
        padding-left: 15px;
        margin-top: 20px;
        text-align: left;
      }
      .symbol {
        font-size: 80px;
        cursor: pointer;
        transition: transform 0.2s;
      }
      .symbol:hover {
        transform: scale(1.1);
      }
      .btn-custom {
        background-color: #dcaea3;
        color: white;
        font-weight: bold;
        border: none;
        padding: 10px 20px;
        border-radius: 10px;
        box-shadow: 0 2px 6px rgba(0,0,0,0.2);
        margin-top: 20px;
        font-size: 1rem;
      }

      /* -------- Responsive Anpassungen -------- */
      @media (max-width: 768px) {
        h2 {
          font-size: 1.5rem;
        }
        .inhaltbox {
          padding: 20px 15px;
        }
        .symbol {
          font-size: 60px;
        }
        .btn-custom {
          width: 100%;
          font-size: 1rem;
        }
      }

      @media (max-width: 480px) {
        .symbol {
          font-size: 48px;
        }
        .btn-custom {
          font-size: 0.95rem;
          padding: 12px;
        }
      }
    ")),
    tags$script(HTML("
      Shiny.addCustomMessageHandler('setStationIndex', function(value) {
        localStorage.setItem('stationIndex', value);
      });
      document.addEventListener('DOMContentLoaded', function() {
        var savedIndex = localStorage.getItem('stationIndex');
        if (savedIndex !== null) {
          Shiny.setInputValue('loadStationIndex', parseInt(savedIndex));
        }
      });
    "))
  ),
  div(class = "inhaltbox",
      uiOutput("inhalt"),
      uiOutput("symbol_click_text"),
      uiOutput("button_ui")
  ),
  div(style = "margin: 30px auto 80px auto; max-width: 700px; padding: 0 15px;",
      leafletOutput("karte", height = "300px"))
)


server <- function(input, output, session) {
  start_phase <- reactiveVal(TRUE)
  station_index <- reactiveVal(1)
  zeige_text <- reactiveVal(FALSE)
  
  output$inhalt <- renderUI({
    if (start_phase()) {
      tagList(
        h2("🎉 Alles Gute zum Geburtstag, Mama!"),
        p("Heute nehmen wir dich mit auf eine ganz besondere Reise durch Kopenhagen."),
        p("An 7 wunderschönen Stationen – beginnend bei uns im Airbnb – erfährst du nicht nur etwas über die Stadt, sondern auch, was du uns bedeutest."),
        p("Klick bei jedem Ort auf das Symbol – dann verraten wir dir etwas ganz Persönliches 💖")
      )
    } else {
      station <- stationen[station_index(), ]
      tagList(
        h2(station$name),
        p(station$ort_info),
        tags$div(
          span(class = "symbol", id = "symbolID", station$symbol),
          onclick = "Shiny.setInputValue('symbolClicked', Math.random())"
        )
      )
    }
  })
  
  output$symbol_click_text <- renderUI({
    if (!start_phase() && zeige_text()) {
      tags$blockquote(stationen$mama_liebe[station_index()])
    }
  })
  
  output$button_ui <- renderUI({
    if (start_phase()) {
      actionButton("start", "Los geht’s!", class = "btn-custom")
    } else if (zeige_text()) {
      actionButton("weiter", "Weiter zur nächsten Station", class = "btn-custom")
    }
  })
  
  output$karte <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 12.5782, lat = 55.7130, zoom = 12)
  })
  
  observeEvent(input$start, {
    start_phase(FALSE)
    zeige_text(FALSE)
    leafletProxy("karte") %>%
      addMarkers(
        lng = stationen$lng[1],
        lat = stationen$lat[1],
        popup = stationen$name[1]
      )
  })
  
  observeEvent(input$symbolClicked, {
    zeige_text(TRUE)
  })
  
  observeEvent(input$weiter, {
    i <- station_index()
    if (i < nrow(stationen)) {
      station_index(i + 1)
      zeige_text(FALSE)
      coords <- stationen[1:(i + 1), c("lng", "lat")]
      leafletProxy("karte") %>%
        addMarkers(lng = stationen$lng[i + 1],
                   lat = stationen$lat[i + 1],
                   popup = stationen$name[i + 1]) %>%
        clearGroup("route") %>%
        addPolylines(
          lng = coords$lng,
          lat = coords$lat,
          group = "route",
          color = "blue",
          weight = 4,
          opacity = 0.8
        )
    } else {
      showModal(modalDialog(
        title = "🎉 Du hast alle Orte besucht!",
        "Danke, dass du mit uns durch Kopenhagen gereist bist. Wir haben dich sehr lieb ❤️",
        easyClose = TRUE,
        footer = NULL
      ))
    }
  })
  
  # Fortschritt speichern bei jedem Schritt
  observe({
    session$sendCustomMessage("setStationIndex", station_index())
  })
  
  # Fortschritt beim Laden aus localStorage abrufen
  observeEvent(input$loadStationIndex, {
    i <- input$loadStationIndex
    if (i >= 1 && i <= nrow(stationen)) {
      start_phase(FALSE)
      station_index(i)
      zeige_text(FALSE)
      
      coords <- stationen[1:i, c("lng", "lat")]
      leafletProxy("karte") %>%
        clearMarkers() %>%
        clearGroup("route") %>%
        addMarkers(lng = stationen$lng[1:i],
                   lat = stationen$lat[1:i],
                   popup = stationen$name[1:i]) %>%
        addPolylines(
          lng = coords$lng,
          lat = coords$lat,
          group = "route",
          color = "blue",
          weight = 4,
          opacity = 0.8
        )
    }
  })
}

shinyApp(ui = ui, server = server)
