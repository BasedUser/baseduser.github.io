#!/bin/bash
echo -e "krakozyabry.sh\tv1.0"
echo "" # похуй
echo "This script is distributed under the terms of the GNU General Public License version 2 (see https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt)."
echo "Этот скрипт распространяется на условиях GNU General Public License версии 2 (см. ссылку выше)."
echo "© BasedUser, 2024"

YELLOW=$(echo -ne "\e[93m")
GREEN=$(echo -ne "\e[92m")
RED=$(echo -ne "\e[91m")
CLEAR=$(echo -ne "\e[39m")

XKB_SYMBOLS_DIR="/usr/share/X11/xkb/symbols"
XKB_RULES_DIR="/usr/share/X11/xkb/rules"
LAYOUT_FILE="$XKB_SYMBOLS_DIR/ru_MB"
EVDEV_XML="$XKB_RULES_DIR/evdev.xml"
EVDEV_LST="$XKB_RULES_DIR/evdev.lst"

# ага, а мастер кто будет пушить? Торвальдс?
LAYOUT_URL="https://baseduser.github.io/ru_MB"

check_layout() {
    echo -e "${YELLOW}Проверка наличия раскладки ru_MB...${CLEAR}"
    if [ -f "$LAYOUT_FILE" ]; then
        echo -e "${GREEN}Файл раскладки ru_MB существует в $LAYOUT_FILE${CLEAR}"
    else
        echo -e "${RED}Файл раскладки ru_MB не найден в $LAYOUT_FILE${CLEAR}"
    fi

    if grep -q "ru_MB" "$EVDEV_XML"; then
        echo -e "${GREEN}Раскладка ru_MB зарегистрирована в evdev.xml${CLEAR}"
    else
        echo -e "${RED}Раскладка ru_MB не найдена в evdev.xml${CLEAR}"
    fi

    if grep -q "ru_MB" "$EVDEV_LST"; then
        echo -e "${GREEN}Раскладка ru_MB присутствует в evdev.lst${CLEAR}"
    else
        echo -e "${RED}Раскладка ru_MB не найдена в evdev.lst${CLEAR}"
    fi
}

install_layout() {
    echo -e "${YELLOW}Установка раскладки ru_MB...${CLEAR}"

    TEMP_FILE=$(mktemp)
    echo -e "${YELLOW}Временный файл для загрузки: $TEMP_FILE${CLEAR}"

    echo -e "${GREEN}\$ curl -o \"$TEMP_FILE\" \"$LAYOUT_URL\"${CLEAR}"
    curl -o "$TEMP_FILE" "$LAYOUT_URL"

    echo -e "${RED}\$ sudo cp \"$TEMP_FILE\" \"$LAYOUT_FILE\"${CLEAR}"
    sudo cp "$TEMP_FILE" "$LAYOUT_FILE"

    echo -e "${YELLOW}Удаление временного файла $TEMP_FILE...${CLEAR}"
    rm -f "$TEMP_FILE"

    # БЭКАП СУКА
    echo -e "${RED}\$ sudo cp \"$EVDEV_XML\" \"${EVDEV_XML}.bak\"${CLEAR}"
    sudo cp "$EVDEV_XML" "${EVDEV_XML}.bak"
    echo -e "${RED}\$ sudo cp \"$EVDEV_LST\" \"${EVDEV_LST}.bak\"${CLEAR}"
    sudo cp "$EVDEV_LST" "${EVDEV_LST}.bak"

    echo -e "${RED}\$ sudo sed -i '/<\/layoutList>/i \\\\${YELLOW}\\\\n[...]${RED}' \"$EVDEV_XML\"${CLEAR}"
    sudo sed -i '/<\/layoutList>/i \
        <layout>\
            <configItem>\
                <name>ru_MB<\/name>\
                <shortDescription>ru_MB<\/shortDescription>\
                <description>Russian (Mojibake)<\/description>\
                <languageList>\
                    <iso639Id>rus<\/iso639Id>\
                </languageList>\
            </configItem>\
        </layout>' "$EVDEV_XML"

    echo -e "${RED}\$ sudo sed -i '/! layout/a \\\\${YELLOW}\\\\n${RED}  ru_MB          Russian (Mojibake)' \"$EVDEV_LST\"${CLEAR}"
    sudo sed -i '/! layout/a \
  ru_MB          Russian\ \(Mojibake\)' "$EVDEV_LST"

    echo -e "${YELLOW}Компиляция обновленных данных XKB с помощью xkbcomp...${CLEAR}"
    echo -e "${GREEN}\$ xkbcomp -I/usr/share/X11/xkb \"$DISPLAY\""
    xkbcomp -I/usr/share/X11/xkb "$DISPLAY"

    echo -e "${GREEN}Установка завершена.${CLEAR}"
    echo -e "${YELLOW}Если раскладка не применяется после добавления, перезапустите графическую сессию или выполните logout/login.${CLEAR}"
}

# дэйнджер - йуо мэй дай!
# 💀
uninstall_layout() {
    echo -e "${YELLOW}Удаление раскладки ru_MB...${CLEAR}"

    if [ -f "$LAYOUT_FILE" ]; then
        echo -e "${RED}\$ sudo rm -f \"$LAYOUT_FILE\"${CLEAR}"
        sudo rm -f "$LAYOUT_FILE"
    else
        echo -e "${RED}Файл раскладки $LAYOUT_FILE не найден.${CLEAR}"
    fi

    echo -e "${RED}\$ sudo sed -i '/<layout>/,/<\/layout>/ { /<name>ru_MB<\/name>/,/<\/layout>/d }' \"$EVDEV_XML\"${CLEAR}"
    sudo sed -i '/<layout>/,/<\/layout>/{
         /<name>ru_MB<\/name>/,/<\/layout>/d
    }' "$EVDEV_XML"

    echo -e "${RED}\$ sudo sed -i '/ru_MB\s\\+Russian (Mojibake)/d' \"$EVDEV_LST\"${CLEAR}"
    sudo sed -i '/ru_MB\s\\+Russian (Mojibake)/d' "$EVDEV_LST"

    echo -e "${YELLOW}Компиляция обновленных данных XKB с помощью xkbcomp...${CLEAR}"
    echo -e "${GREEN}\$ xkbcomp -I/usr/share/X11/xkb \"$DISPLAY\""
    xkbcomp -I/usr/share/X11/xkb "$DISPLAY"

    echo -e "${GREEN}Удаление завершено.${CLEAR}"
    echo -e "${YELLOW}Если раскладка не пропадает, перезапустите графическую сессию или выполните logout/login.${CLEAR}"
}

case "$1" in
    install)
        install_layout
        ;;
    uninstall)
        uninstall_layout
        ;;
    status)
        check_layout
        ;;
    *)
        echo -e "${RED}Использование: $0 {install|uninstall|status}${CLEAR}"
        exit 1
        ;;
esac
