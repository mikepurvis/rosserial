cmake_minimum_required(VERSION 2.8.3)

function(rosserial_client_generate_ros_lib)
  cmake_parse_arguments(make_libraries "" "PACKAGE;SCRIPT" "" ${ARGN}) 
  if(NOT make_libraries_PACKAGE)
    set(make_libraries_PACKAGE rosserial_client)
  endif()
  if(NOT make_libraries_SCRIPT)
    set(make_libraries_SCRIPT make_libraries)
  endif()

  message(STATUS "Using ${make_libraries_PACKAGE}/${make_libraries_SCRIPT} to make rosserial client library.")

  add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/ros_lib
    COMMAND ${CATKIN_ENV} rosrun ${make_libraries_PACKAGE} ${make_libraries_SCRIPT} ${PROJECT_BINARY_DIR}
  )
  add_custom_target(${PROJECT_NAME}_ros_lib DEPENDS ${PROJECT_BINARY_DIR}/ros_lib)
  add_dependencies(${PROJECT_NAME}_ros_lib rosserial_msgs_genpy std_msgs_genpy)
  set(${PROJECT_NAME}_ROS_LIB_DIR "${PROJECT_BINARY_DIR}/ros_lib" PARENT_SCOPE)
endfunction()

function(rosserial_client_add_client)
  cmake_parse_arguments(client "" "DIRECTORY;TOOLCHAIN_FILE" "TARGETS" ${ARGN})
  if(NOT client_DIRECTORY)
    message(SEND_ERROR "rosserial_client_add_client called without DIRECTORY argument.")
  endif()
  if(NOT client_TARGETS)
    message(SEND_ERROR "rosserial_client_add_client called with no TARGETS specified.")
  endif()

  # Create a build tree directory for configuring the client's CMake project.
  file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/${client_DIRECTORY})
  add_custom_target(${PROJECT_NAME}_${client_DIRECTORY} ALL
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/${client_DIRECTORY}
    COMMAND ${CMAKE_COMMAND} ${PROJECT_SOURCE_DIR}/${client_DIRECTORY}
      -DROS_LIB_DIR=${${PROJECT_NAME}_ROS_LIB_DIR}
      -DPACKAGE_SOURCE_DIR=${PROJECT_SOURCE_DIR}
      -DEXECUTABLE_OUTPUT_PATH=${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_SHARE_DESTINATION}
      -DCMAKE_TOOLCHAIN_FILE=${client_TOOLCHAIN_FILE}
    COMMAND ${CMAKE_COMMAND} --build ${PROJECT_BINARY_DIR}/${client_DIRECTORY} -- ${client_TARGETS}
  )

  # Depend on the ros lib being built.
  add_dependencies(${PROJECT_NAME}_firmware ${PROJECT_NAME}_ros_lib)
endfunction()
