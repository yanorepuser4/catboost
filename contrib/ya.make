# TO ADD SUBDIRECTORIES TO THE AUTOCHECK,
# ADD THEM TO THE ${ARCADIA_ROOT}/autocheck/recurses/contrib.inc FILE
IF (NOT AUTOCHECK)
    INCLUDE(${ARCADIA_ROOT}/autocheck/recurses/contrib.inc)
    RECURSE_ROOT_RELATIVE(
        ${CONTRIB}
    )
ENDIF()

RECURSE(
    
)
