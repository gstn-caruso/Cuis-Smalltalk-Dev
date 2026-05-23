# Cuis Smalltalk

[![CI](https://github.com/gstn-caruso/Cuis-Smalltalk-Dev/actions/workflows/ci.yml/badge.svg)](https://github.com/gstn-caruso/Cuis-Smalltalk-Dev/actions/workflows/ci.yml)
[![Release](https://github.com/gstn-caruso/Cuis-Smalltalk-Dev/releases/latest)](https://github.com/gstn-caruso/Cuis-Smalltalk-Dev/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Un sistema [Smalltalk-80](https://en.wikipedia.org/wiki/Smalltalk) limpio y minimalista.

Este fork de [Cuis-Smalltalk/Cuis-Smalltalk-Dev](https://github.com/Cuis-Smalltalk/Cuis-Smalltalk-Dev) existe para bajar la barrera de entrada: Smalltalk vale la pena aprenderlo, y arrancar no debería ser la parte difícil.

Mantenido por [Gastón Caruso](https://github.com/gstn-caruso).

Este repositorio respeta a upstream y su linaje, pero es estricto con el alcance. Si algo no ayuda a quienes están empezando, no pertenece a este fork o está mejor documentado en otro lado, hay que cuestionarse si tiene lugar acá.

La documentación está dividida en:

- Wiki (curada, en evolución): https://github.com/gstn-caruso/Cuis-Smalltalk-Dev/wiki
- `Documentation/` (docs de upstream, espejadas acá)

## Inicio rápido

```sh
git clone https://github.com/gstn-caruso/Cuis-Smalltalk-Dev.git
cd Cuis-Smalltalk-Dev
```

| Plataforma | Comando |
|---|---|
| macOS | `./RunCuisOnMac.sh` |
| Linux | `./RunCuisOnLinux.sh` |
| Windows | `RunCuisOnWindows.bat` |
| macOS (Finder) | Doble clic en `RunCuisOnFinder.command` |

> **macOS + descarga ZIP:** ejecutá `./unquarantine.sh` primero para permitir que la VM se ejecute.

## Qué hay adentro

```
Cuis-Smalltalk-Dev/
├── CuisImage/          # Imagen Smalltalk viva + fuentes
├── CuisVM.app/         # Binarios de la VM (macOS, Linux, Windows)
├── CoreUpdates/        # Changesets numerados — release rolling
├── Packages/           # Paquetes opcionales: tests, herramientas, FFI, temas…
├── CompatibilityPackages/
├── Documentation/      # Guías, filosofía, notas técnicas
└── TrueTypeFonts/
```

El sistema viene como una única imagen (`CuisImage/Cuis7.7-7777.image`) más changesets numerados en `CoreUpdates/`. Cargalos en orden para mantenerte actualizado.

## Tests

Los tests corren automáticamente en cada push vía GitHub Actions — amd64 vía Docker, arm64 bare-metal.

La suite principal es `Packages/BaseImageTests.pck.st`.

## Releases

Los releases son completamente automáticos usando [semantic-release](https://semantic-release.gitbook.io) y [Conventional Commits](https://www.conventionalcommits.org).

### Cómo funciona

1. Cada PR se mergea a `main` con commits en formato Conventional Commits.
2. Al mergear, el CI corre los tests en amd64 y arm64.
3. Si los tests pasan, semantic-release analiza los commits desde el último tag y calcula el bump de versión.
4. Se crea automáticamente un tag `vX.Y.Z` en git.
5. Ese tag dispara el workflow de release, que construye y publica los artefactos.

### Reglas de versionado (SemVer)

| Tipo de commit | Bump | Ejemplo |
|---|---|---|
| `fix:` | **patch** `0.0.X` | `fix: corregir carga de fuentes en Linux` |
| `feat:` | **minor** `0.X.0` | `feat: agregar soporte para ARM64` |
| `BREAKING CHANGE:` | **major** `X.0.0` | `feat!: cambiar formato de imagen` |

### Formato de commits

```
<tipo>[alcance opcional]: <descripción>

[cuerpo opcional]

[BREAKING CHANGE: descripción opcional]
```

Tipos válidos: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`.

Solo `feat` y `fix` generan un nuevo release. `BREAKING CHANGE` en el footer (o `!` después del tipo) genera un major.

### Artefactos publicados

Cada release incluye:
- Imagen Smalltalk con todos los core updates aplicados
- ZIPs listos para usar por plataforma (macOS, Linux x86_64)
- Imágenes Docker headless para linux/amd64 y linux/arm64

## La VM

Cuis corre sobre la [OpenSmalltalk VM](https://github.com/OpenSmalltalk/opensmalltalk-vm). Las fuentes de la VM viven en ese repositorio.

Los binarios precompilados para macOS, Linux y Windows están incluidos en `CuisVM.app/`.

## Contribuciones

Leé [CONTRIBUTING.md](CONTRIBUTING.md) y la wiki del proyecto antes de mandar patches o PRs.

Resumen: las contribuciones deben estar bajo licencia MIT e incluir un [Developer Certificate of Origin](DCO). Mantené los commits pequeños y enfocados — limpieza estructural y cambios de comportamiento van en commits separados.

Los cambios que pertenecen al Cuis upstream deben contribuirse directamente allá: [Cuis-Smalltalk/Cuis-Smalltalk-Dev](https://github.com/Cuis-Smalltalk/Cuis-Smalltalk-Dev).

## Créditos

- **Juan Vuletich** — creador y autor principal de Cuis Smalltalk
- **Gastón Caruso** — mantenedor de este fork
- **Máximo Prieto** — contribuidor a este fork
- **OpenSmalltalk VM team** — la máquina virtual sobre la que corre
- Contribuidores de Squeak (1997–presente)
- Xerox PARC y Apple (Smalltalk-80 original, 1981–1996)

Lista completa de contribuidores en [AUTHORS](AUTHORS).

## Licencia

[MIT](LICENSE). Copyright (c) Xerox Corp. 1981–1982, Apple Computer 1985–1996, Squeak contributors 1997–present, Cuis contributors 2009–present.
