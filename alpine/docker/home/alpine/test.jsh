//usr/bin/env jshell --show-version "$0" "$@"; exit $?
import java.awt.*;
import java.io.*;

System.out.println("Hello World")
boolean headless = GraphicsEnvironment.getLocalGraphicsEnvironment().isHeadless();
System.out.println(String.format("Headless: %s", headless));
Font font = Font.createFont(Font.TRUETYPE_FONT, new File("HuaKangShouZhaTiw5-1.ttf")).deriveFont(Font.TRUETYPE_FONT, 20F);
System.out.println(font);
/exit
