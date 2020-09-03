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

ENV FLUTTER_VERSION=1.22.0-1.0.pre
ENV FLUTTER_BRANCH=dev


ENV HOME=/home/theia

ENV FLUTTER_HOME=${HOME}/sdks/flutter 
ENV FLUTTER_ROOT=${FLUTTER_HOME}

RUN mkdir -p ${FLUTTER_HOME} 
RUN echo '{\n\
    "enable-web": true\n\
    }\n'\
    >> ${HOME}/.flutter_settings

RUN cat ${HOME}/.flutter_settings

RUN wget https://storage.googleapis.com/flutter_infra/releases/${FLUTTER_BRANCH}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_BRANCH}.tar.xz 
RUN tar -xf flutter_linux_${FLUTTER_VERSION}-${FLUTTER_BRANCH}.tar.xz -C ${HOME}/sdks/
RUN rm -f flutter_linux_${FLUTTER_VERSION}-${FLUTTER_BRANCH}.tar.xz

ENV PATH ${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin
ENV PATH ${PATH}:${HOME}/sdks/flutter/.pub-cache/bin
ENV PATH ${PATH}:${HOME}/.pub-cache/bin

RUN sdkmanager --update
RUN flutter upgrade
RUN flutter config global --enable-web
RUN pub global activate webdev
RUN pub global activate grinder
RUN yes | flutter doctor --android-licenses && flutter doctor

RUN mkdir /projects && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects" "/opt"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done
    
ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
