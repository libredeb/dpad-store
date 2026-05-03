project(
    'io.github.libredeb.dpad-store',
    'vala', 'c',
    version: '0.1.0',
    meson_version: '>=0.56.0'
)

add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

# Generar Config.vala desde Config.vala.in con las variables de localización
config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

PROJECT_NAME = 'D-Pad Store'
prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))
datadir = join_paths(prefix, get_option('datadir'))

VAPI_DIR = join_paths(meson.project_source_root(), 'vapi')
vala = meson.get_compiler('vala')

# Generar config.h con metadatos del proyecto (leídos desde config.vapi)
conf = configuration_data()
conf.set_quoted('PROJECT_NAME', PROJECT_NAME)
conf.set_quoted('PACKAGE_LIBDIR', libdir)
conf.set_quoted('PACKAGE_SHAREDIR', datadir)
conf.set_quoted('PACKAGE_VERSION', meson.project_version())

config_h = configure_file(
    output: 'config.h',
    configuration: conf
)

config_dep = declare_dependency(
    dependencies: vala.find_library('config', dirs: VAPI_DIR),
    sources: config_h
)

config_inc_dir = include_directories('.')

# Compilar recursos GTK (CSS, etc.)
gnome = import('gnome')
asresources = gnome.compile_resources(
    'as-resources',
    join_paths('data', meson.project_name() + '.gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)

ValaArgs = [
    '--pkg=config',
    '--pkg=sdl2',
    '--vapidir=' + VAPI_DIR
]

executable(
    meson.project_name(),
    config_file,
    asresources,
    'src/Backend/AppInfo.vala',
    'src/Backend/AppLoader.vala',
    'src/Backend/CatalogService.vala',
    'src/Backend/GamepadManager.vala',
    'src/Backend/IconService.vala',
    'src/Backend/Installer.vala',
    'src/Widgets/AppTile.vala',
    'src/Widgets/ConsoleOutput.vala',
    'src/Widgets/DetailPanel.vala',
    'src/Widgets/MainWindow.vala',
    'src/Constants.vala',
    'src/Application.vala',
    'src/Main.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('gio-unix-2.0'),
        dependency('gtk+-3.0'),
        dependency('sdl2'),
        dependency('libsoup-2.4'),
        dependency('json-glib-1.0'),
    ],
    c_args: [
        '-w'
    ],
    vala_args: ValaArgs,
    include_directories: config_inc_dir,
    install: true
)

i18n = import('i18n')

i18n.merge_file(
    input: join_paths('data', meson.project_name() + '.desktop.in'),
    output: meson.project_name() + '.desktop',
    type: 'desktop',
    po_dir: join_paths(meson.project_source_root(), 'po'),
    install: true,
    install_dir: join_paths(datadir, 'applications')
)

run_command('gzip', '-fk', join_paths('data', meson.project_name() + '.1'), check: true)
install_data(
    join_paths('data', meson.project_name() + '.1.gz'),
    install_dir: join_paths(datadir, 'man', 'man1')
)

install_data(
    join_paths('data', 'icons', '128', 'dpad-store.svg'),
    install_dir: join_paths(datadir, 'icons', 'hicolor', '128x128', 'apps'),
    rename: meson.project_name() + '.svg'
)

gfx_files = ['d-pad.svg', 'control_A.png', 'controls_B.png']
foreach gfx : gfx_files
    install_data(
        join_paths('data', 'gfx', gfx),
        install_dir: join_paths(datadir, 'dpad-store', 'gfx')
    )
endforeach

# Install the gamecontrollerdb.txt file
install_data(
    join_paths('data', 'gamecontrollerdb.txt'),
    install_dir: join_paths(datadir, 'dpad-store')
)

meson.add_install_script('post_install.py')
