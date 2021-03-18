/*
 * HOWTO write an External for Pure data
 * (c) 2001-2006 IOhannes m zmölnig zmoelnig[AT]iem.at
 *
 * this is the source-code for the fourth example in the HOWTO
 * it creates a simple dsp-object:
 * 2 input signals are mixed into 1 output signal
 * the mixing-factor can be set via the 3rd inlet
 *
 * for legal issues please see the file LICENSE.txt
 */


/**
 * include the interface to Pd
 */
#include "m_pd.h"


/**
 * define a new "class"
 */
static t_class *xfade_tilde_class;


/**
 * this is the dataspace of our new object
 * the first element is the mandatory "t_object"
 * x_pan denotes the mixing-factor
 * "f" is a dummy and is used to be able to send floats AS signals.
 */
typedef struct _xfade_tilde {
  t_object x_obj;
  t_float x_pan;
  t_float f;

  t_inlet *x_in2;
  t_inlet *x_in3;
  t_outlet*x_out;
} t_xfade_tilde;


/**
 * this is the core of the object
 * this perform-routine is called for each signal block
 * the name of this function is arbitrary and is registered to Pd in the
 * xfade_tilde_dsp() function, each time the DSP is turned on
 *
 * the argument to this function is just a pointer within an array
 * we have to know for ourselves how many elements inthis array are
 * reserved for us (hint: we declare the number of used elements in the
 * xfade_tilde_dsp() at registration
 *
 * since all elements are of type "t_int" we have to cast them to whatever
 * we think is apropriate; "apropriate" is how we registered this function
 * in xfade_tilde_dsp()
 */
t_int *xfade_tilde_perform(t_int *w)
{
  /* the first element is a pointer to the dataspace of this object */
  t_xfade_tilde *x = (t_xfade_tilde *)(w[1]);
  /* here is a pointer to the t_sample arrays that hold the 2 input signals */
  t_sample    *in1 =      (t_sample *)(w[2]);
  t_sample    *in2 =      (t_sample *)(w[3]);
  /* here comes the signalblock that will hold the output signal */
  t_sample    *out =      (t_sample *)(w[4]);
  /* all signalblocks are of the same length */
  int            n =             (int)(w[5]);
  /* get (and clip) the mixing-factor */
  t_sample pan = (x->x_pan<0)?0.0:(x->x_pan>1)?1.0:x->x_pan;
  /* just a counter */
  int i;

  /* this is the main routine:
   * mix the 2 input signals into the output signal
   */
  for(i=0; i<n; i++)
    {
      out[i]=in1[i]*(1-pan)+in2[i]*pan;
    }

  /* return a pointer to the dataspace for the next dsp-object */
  return (w+6);
}


/**
 * register a special perform-routine at the dsp-engine
 * this function gets called whenever the DSP is turned ON
 * the name of this function is registered in xfade_tilde_setup()
 */
void xfade_tilde_dsp(t_xfade_tilde *x, t_signal **sp)
{
  /* add xfade_tilde_perform() to the DSP-tree;
   * the xfade_tilde_perform() will expect "5" arguments (packed into an
   * t_int-array), which are:
   * the objects data-space, 3 signal vectors (which happen to be
   * 2 input signals and 1 output signal) and the length of the
   * signal vectors (all vectors are of the same length)
   */
  dsp_add(xfade_tilde_perform, 5, x,
          sp[0]->s_vec, sp[1]->s_vec, sp[2]->s_vec, sp[0]->s_n);
}

/**
 * this is the "destructor" of the class;
 * it allows us to free dynamically allocated ressources
 */
void xfade_tilde_free(t_xfade_tilde *x)
{
  /* free any ressources associated with the given inlet */
  inlet_free(x->x_in2);
  inlet_free(x->x_in3);

  /* free any ressources associated with the given outlet */
  outlet_free(x->x_out);
}

/**
 * this is the "constructor" of the class
 * the argument is the initial mixing-factor
 */
void *xfade_tilde_new(t_floatarg f)
{
  t_xfade_tilde *x = (t_xfade_tilde *)pd_new(xfade_tilde_class);

  /* save the mixing factor in our dataspace */
  x->x_pan = f;

  /* create a new signal-inlet */
  x->x_in2 = inlet_new(&x->x_obj, &x->x_obj.ob_pd, &s_signal, &s_signal);

  /* create a new passive inlet for the mixing-factor */
  x->x_in3 = floatinlet_new (&x->x_obj, &x->x_pan);

  /* create a new signal-outlet */
  x->x_out = outlet_new(&x->x_obj, &s_signal);

  return (void *)x;
}


/**
 * define the function-space of the class
 * within a single-object external the name of this function is very special
 */
void xfade_tilde_setup(void) {
  xfade_tilde_class = class_new(gensym("xfade~"),
        (t_newmethod)xfade_tilde_new,
        (t_method)xfade_tilde_free,
        sizeof(t_xfade_tilde),
        CLASS_DEFAULT,
        A_DEFFLOAT, 0);

  /* whenever the audio-engine is turned on, the "xfade_tilde_dsp()"
   * function will get called
   */
  class_addmethod(xfade_tilde_class,
      (t_method)xfade_tilde_dsp, gensym("dsp"), A_CANT, 0);
  /* if no signal is connected to the first inlet, we can as well
   * connect a number box to it and use it as "signal"
   */
  CLASS_MAINSIGNALIN(xfade_tilde_class, t_xfade_tilde, f);
}
