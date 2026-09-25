def pedir_numero(texto: str) -> int:
    while True:
        raw_text: str = input(f"{texto}: ").strip()
        print()
        if raw_text:
            try:
                return int(raw_text)
            except Exception:
                msg = "No se puede procesar el valor ingresado. " "Intente nuevamente."
                print(msg)
                continue
        print("  Campo obligatorio.")


def pedir_numero_opcional(texto: str) -> int | None:
    while True:
        raw_text: str = input(f"{texto}: ").strip()
        print()
        try:
            if raw_text:
                return int(raw_text)
            else:
                return None
        except Exception:
            msg = "No se puede procesar el valor ingresado. " "Intente nuevamente."
            print(msg)
            continue


def pedir_texto(texto: str) -> str:
    raw_text: str = input(f"{texto}: ").strip()
    print()
    while True:
        if raw_text:
            return raw_text
        else:
            print("  Campo obligatorio.")


def pedir_texto_opcional(texto: str) -> None | str:
    raw_text: str = input(f"{texto}: ").strip()
    print()
    if raw_text:
        return raw_text
    else:
        return None
