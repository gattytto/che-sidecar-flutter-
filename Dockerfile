# Copyright (c) 2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
#   Lining Pan

FROM cirrusci/android-sdk:30
USER root

ENV HOME=/home/theia

ENV FLUTTER_HOME=${HOME}/sdks/flutter 
ENV FLUTTER_ROOT=${FLUTTER_HOME}
ENV PATH ${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin
ENV PATH ${PATH}:${HOME}/sdks/flutter/.pub-cache/bin
ENV PATH ${PATH}:${HOME}/.pub-cache/bin

RUN mkdir -p ${FLUTTER_HOME} && \
    echo '{\n\
        "enable-web": true\n\
    }\n'\
    >> ${HOME}/.flutter_settings && \
    git clone -b master https://github.com/flutter/flutter.git ${HOME}/sdks/flutter && \
    sdkmanager --update && \
    flutter upgrade && \
    flutter config global --enable-web && \
    pub global activate webdev && \
    pub global activate grinder && \
    yes | flutter doctor --android-licenses && flutter doctor && flutter precache 

RUN mkdir /projects && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects" "/opt"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done

ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
