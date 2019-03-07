(* Distributed under the terms of the MIT license.   *)

From Coq Require Import Bool String List Program BinPos Compare_dec Arith Lia.
From Template
Require Import config univ monad_utils utils BasicAst AstUtils UnivSubst.
From PCUIC Require Import PCUICAst PCUICAstUtils PCUICInduction PCUICLiftSubst PCUICUnivSubst PCUICTyping.
From Equations Require Import Equations.

Import MonadNotation.

(** * Type checker for PCUIC without fuel

  *WIP*

  The idea is to subsume PCUICChecker by providing a fuel-free implementation
  of reduction, conversion and type checking.

  We will follow the same structure, except that we assume normalisation of
  the system. Since we will be using an axiom to justify termination, the checker
  won't run inside Coq, however, its extracted version should correspond more or less
  to the current implementation in ocaml, except it will be certified.

 *)

Module RedFlags.

  Record t := mk {
    beta   : bool ;
    iota   : bool ;
    zeta   : bool ;
    delta  : bool ;
    fix_   : bool ;
    cofix_ : bool
  }.

  Definition default := mk true true true true true true.

End RedFlags.

(* We assume normalisation of the reduction.

   We state is as well-foundedness of the reduction.
   This seems to be slightly stronger than simply assuming there are no infinite paths.
   This is however the version we need to do well-founded recursion.
*)
Section Normalisation.

  Context (flags : RedFlags.t).
  Context `{checker_flags}.

  Definition cored Σ Γ u v := red Σ Γ v u.

  Axiom normalisation :
    forall Σ Γ t A,
      Σ ;;; Γ |- t : A ->
      Acc (cored (fst Σ) Γ) t.

End Normalisation.

Section Reduce.

  Context (flags : RedFlags.t).

  Context (Σ : global_context).

  Context `{checker_flags}.

  Definition zip (t : term * list term) := mkApps (fst t) (snd t).

  (* TODO Get equations in obligations *)
  (* Equations _reduce_stack (Γ : context) (t : term) (stack : list term) *)
  (*           (h : closedn #|Γ| t = true) *)
  (*           (reduce : forall Γ t' (stack : list term) (h : closedn #|Γ| t' = true), red Σ Γ t t' -> term * list term) *)
  (*   : term * list term := *)
  (*   _reduce_stack Γ (tRel c) stack h reduce with RedFlags.zeta flags := { *)
  (*   | true with nth_error Γ c := { *)
  (*     | None := ! ; *)
  (*     | Some d with d.(decl_body) := { *)
  (*       | None := (tRel c, stack) ; *)
  (*       | Some b := reduce Γ (lift0 (S c) b) stack _ _ *)
  (*       } *)
  (*     } ; *)
  (*   | false := (tRel c, stack) *)
  (*   } ; *)
  (*   _reduce_stack Γ t stack h reduce := (t, stack). *)
  (* Next Obligation. *)
  (* Admitted. *)
  (* Next Obligation. *)
  (*   econstructor. *)
  (*   - econstructor. *)
  (*   - econstructor. *)
  (* Admitted. *)
  (* Next Obligation. *)
  (* Abort. *)

  Program Definition _reduce_stack Γ t stack
             (h : closedn #|Γ| t = true)
             (reduce : forall t', red (fst Σ) Γ t t' -> term * list term)
    : term * list term :=
    match t with
    | tRel c =>
      if RedFlags.zeta flags then
        match nth_error Γ c with
        | None => !
        | Some d =>
          match d.(decl_body) with
          | None => (t, stack)
          | Some b => reduce (lift0 (S c) b) _
          end
        end
      else (t, stack)

    | tLetIn _ b _ c =>
      if RedFlags.zeta flags then
        reduce (subst10 b c) _
      else (t, stack)

    | _ => (t, stack)
    end.
  Next Obligation.
    clear - h Heq_anonymous. revert c h Heq_anonymous.
    induction Γ ; intros c h eq.
    - cbn in *. discriminate.
    - destruct c.
      + cbn in eq. discriminate.
      + cbn in eq, h. eapply IHΓ ; eassumption.
  Qed.
  Next Obligation.
    econstructor.
    - econstructor.
    - eapply red_rel.
      rewrite <- Heq_anonymous0. cbn. f_equal. eauto.
  Qed.
  Next Obligation.
    econstructor.
    - econstructor.
    - eapply red_zeta.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.
  Next Obligation.
    split.
    - intros. discriminate.
    - intros. discriminate.
  Qed.

  Lemma closedn_red :
    forall Σ Γ u v,
      red Σ Γ u v ->
      closedn #|Γ| u = true ->
      closedn #|Γ| v = true.
  Admitted.

  Lemma closedn_typed :
    forall Σ Γ t A,
      Σ ;;; Γ |- t : A ->
      closedn #|Γ| t = true.
  Admitted.

  Equations? reduce_stack (Γ : context) (t A : term) (stack : list term)
           (h : Σ ;;; Γ |- t : A) : term * list term :=
    reduce_stack Γ t A stack h :=
      Fix_F (R := cored (fst Σ) Γ)
            (fun x => closedn #|Γ| x = true -> (term * list term)%type)
            (fun t' f => _) (x := t) _ _.
  Proof.
    - { eapply _reduce_stack.
        - exact stack.
        - eassumption.
        - intros t'0 H1. eapply f.
          + eassumption.
          + eapply closedn_red ; eassumption.
      }
    - { eapply normalisation. eassumption. }
    - { eapply closedn_typed. eassumption. }
  Defined.

End Reduce.