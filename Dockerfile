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

FROM cirrusci/android-sdk:29
USER root
ENV FLUTTER_VERSION=1.20.2

ENV HOME=/home/theia

ENV FLUTTER_HOME=${HOME}/sdks/flutter 
ENV FLUTTER_ROOT=${FLUTTER_HOME}



RUN mkdir -p ${FLUTTER_HOME} 
RUN wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz 
RUN tar -xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz -C ${FLUTTER_HOME}/

ENV PATH ${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin

RUN yes | flutter doctor --android-licenses && flutter doctor

RUN mkdir /projects ${HOME} && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done && \
    
    
ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
