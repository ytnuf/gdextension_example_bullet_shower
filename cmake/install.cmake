
install(TARGETS "bullet-shower"
    LIBRARY
        DESTINATION "lib"
)

install(FILES "${PROJECT_SOURCE_DIR}/LICENSE.txt"
    DESTINATION "."
)

install(FILES "${PROJECT_SOURCE_DIR}/data/gd.install.in"
    DESTINATION "."
    RENAME "gdextension_example_bullet_shower.gdextension"
)
