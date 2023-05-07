-- English localization file for esMX.
local L = ElvUI[1].Libs.ACL:NewLocale("ElvUI_EasyBuff", "esMX");

-- Messages
L["%s needs %s"] = "%s necesita %s";
L["Activity context changed to %s"] = "Contexto de la actividad cambió a %s";
L["Talent Spec context changed to %s"] = "Contexto de Especialización de talentos cambió a %s";
L["Announcements"] = "Anuncios";

-- Config Table
L["General"] = "General";
L["Enable"] = "Activar";
L["Enables / disables the addon"] =  "Activar/desactivar el complemento";
L["Active Spec"] =  "Especialización Activa";
L["All Talent Specs"] = "Todas las especializaciones de talento";
L["Primary Spec"] = "Especializaciones primarias";
L["Secondary Spec"] = "Especializaciones Secundarias";
L["Activity Context"] = "Contexto de actividad";
L["Select which context configuration to use. (recommended) Auto-detect will automatically switch the context depending on group size/type, or zone."] = "Seleccione qué configuración de contexto usar. (recomendado) La detección automática cambiará automáticamente el contexto según el tamaño/tipo de grupo o la zona.";
L["All Activities"] = "Todas las actividades";
L["Talent Spec based Config"] = "Configuración basada en especificaciones de talento";
L["Define different buff configuration rules to use when your Secondary Talent Spec is active."] = "Defina diferentes reglas de configuración de Buffs para usar cuando su especificación de talento secundario esté activa.";
L["Activity based Config"] = "Configuración basada en actividad";
L["Define different buff configuration rules for different activities: solo, party, raid, bg."] = "Defina diferentes reglas de configuración de Buffs para diferentes actividades: solo, groupo, mazmorra, campo de batalla";
L["Monitoring"] = "Supervisión";
L["Early Monitoring"] = "Monitoreo Temprano";
L["Auto-Remove before self-buff"] = "Eliminar automáticamente antes de la auto-mejora";
L["Automatically remove buff before applying new buff. Lesser buffs cannot overwrite greater, enabling this feature will ensure refreshing a buff doesn't error. This is only necessary with 'Early Monitoring' enabled."] = "Elimina automáticamente el Buff antes de aplicar un nuevo Buff. Los beneficios menores no pueden sobrescribir los mayores, habilitar esta función garantizará que actualizar un beneficio no produzca errores. Esto solo es necesario con el 'Monitoreo temprano' habilitado.";
L["Announce To"] = "Anunciar a";
L["How would you like to be notified of players missing Buffs?"] = "¿Cómo le gustaría recibir una notificación de los jugadores a los que les faltan Buffs?";
L["HUD is a moveable frame, click 'Toggle Anchors' and move the frame labeled:"] = "HUD es un marco móvil, haga clic en 'Toggle Anchors' y mueva el marco etiquetado:";
L["Chat Window"] = "Ventana de conversación";
L["HUD"] = "HUD";
L["Select the Chat Window to display EasyBuff announcements in."] = "Seleccione la ventana del tanque para mostrar los anuncios de EasyBuff.";
L["Announce Activity Context Change"] = "Anunciar cambio de contexto de actividad";
L["Enable / disable Activity Context Change announcements."] = "Activar/desactivar Anuncios de cambio de contexto de actividad.";
L["Keybinds"] = "Combinación de teclas";
L["Buff Casting bound to key:"] = "Fundición de Buff vinculada a la clave:";
L["Change which key to use to apply buffs."] = "Cambiar qué tecla usar para aplicar Buffs";
L["Buff Removal bound to key:"] = "Eliminación de Buff vinculado a la clave:";
L["Change which key to use to remove unwanted buffs."] = "Cambie qué tecla usar para eliminar los Buffs no deseados.";
L["Solo"] = "Solo";
L["Party"] = "Groupo";
L["Raid"] = "Mazmorra";
L["Battleground"] = "Campo de Batalla";
L["Solo Activity"] = "Actividad de Solo";
L["Party Activity"] = "Actividad de Groupo";
L["Raid Activity"] = "Actividad de Mazmorra";
L["Battleground Activity"] = "Actividad de Campo de Batalla";
L["Wanted Buffs"] = "Buffs buscadas";
L["Unwanted Buffs"] = "Buffs no deseados";
L["Add Unwanted Buff"] = "Agregar Buffs no deseados";
L["Insert Spell name or id"] = "Insertar nombre o id de Hechizo";
L["Click to remove"] = "Haga clic para eliminar";
L["Any Role"] = "Cualquier trabajo";
L["Tank"] = "Tanque";
L["Heal"] = "Sanar";
L["DPS"] = "Daño";
L["Myself"] = "Mí mismo";
L["Configure which buffs you would like to monitor on yourself."] = "Configura qué Buffs te gustaría monitorear en ti mismo.";
L["Configure which buffs you would like to monitor for this class."] = "Configure which Buffs you would like to monitor for this class.";
L["Armor/Aura/Shield"] = "Armadura/Aura/Escudo";
L["Linked buffs that a player may only have one of."] = "";
L["Available Buffs"] = "Buffs disponibles";
L["Disable when Resting"] = "Desactivar al descansar";
L["Disable Monitoring when character is in a 'resting' area."] = "Deshabilite el monitoreo cuando el personaje esté en un área de 'descanso'.";
L["Instance Only"] = "Solo instancia";
L["Disable Monitoring when not in an instance."] = "Deshabilite el monitoreo cuando no esté en una instancia.";
L["Cast on self only"] = "Reproducir solo en uno mismo";
L["Disables buff casting on players other than yourself. You will still be notified of other players needed buffs but you will have to manually buff them."] = "Deshabilita el lanzamiento de Buff en jugadores que no sean usted. Seguirás siendo notificado de otros jugadores que necesitan mejoras, pero tendrás que Buff manualmente.";
L["Copy Configuration From:"] = "Copiar configuración desde:";
L["Select another Activity Context to copy it's configuration into this Activity Context."] = "Seleccione otro Contexto de actividad para copiar su configuración en este Contexto de actividad.";
L["Tracking Ability"] = "Capacidad de seguimiento";
L["Select only one."] = "Seleccione solo uno.";
