#!/bin/fish

set CURRENT_TRAYS (qdbus6 org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.kde.StatusNotifierWatcher.RegisteredStatusNotifierItems | sed 's/\/StatusNotifierItem$//')

echo $CURRENT_TRAYS
