import { createFileRoute } from '@tanstack/react-router';

import { APITester } from '../APITester';
import logo from '../logo.svg';
import reactLogo from '../react.svg';

export const Route = createFileRoute('/')({
  component: () => {
    return (
      <>
        <div className="logo-container">
          <img src={logo} alt="Bun Logo" className="logo bun-logo" />
          <img src={reactLogo} alt="React Logo" className="logo react-logo" />
        </div>

        <h1>Bun + React</h1>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR
        </p>
        <APITester />
      </>
    );
  },
});
