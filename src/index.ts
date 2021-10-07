// Copyright (c) Thorsten Beier
// Distributed under the terms of the Modified BSD License.

import {
  JupyterLiteServer,
  JupyterLiteServerPlugin
} from '@jupyterlite/server';

import { IKernel, IKernelSpecs } from '@jupyterlite/kernel';

import { XeusServerKernel } from './xeus_server_kernel';

const server_kernel: JupyterLiteServerPlugin<void> = {
  id: '@jupyterlite/xeus-wren-extension:kernel',
  autoStart: true,
  requires: [IKernelSpecs],
  activate: (app: JupyterLiteServer, kernelspecs: IKernelSpecs) => {
    kernelspecs.register({
      spec: {
        name: 'Wren',
        display_name: 'Wren',
        language: 'wren',
        argv: [],
        spec: {
          argv: [],
          env: {},
          display_name: 'Wren',
          language: 'wren',
          interrupt_mode: 'message',
          metadata: {}
        },
        resources: {
          'logo-32x32': '/kernelspecs/wren-logo-32x32.png',
          'logo-64x64': '/kernelspecs/wren-logo-64x64.png'
        }
      },
      create: async (options: IKernel.IOptions): Promise<IKernel> => {
        return new XeusServerKernel({
          ...options
        });
      }
    });
  }
};

const plugins: JupyterLiteServerPlugin<any>[] = [server_kernel];

export default plugins;
